#!/bin/bash
set -e  # 遇到错误立即退出

# ================= Signal Handling =================
cleanup() {
    EXIT_CODE=$?
    echo ""
    if [ $EXIT_CODE -eq 130 ]; then
        echo "🛑 [Child] Caught SIGINT (Ctrl-C). Exiting with code 130..."
    elif [ $EXIT_CODE -ne 0 ]; then
        echo "❌ [Child] Process Failed (Exit Code: $EXIT_CODE)."
    fi
    exit $EXIT_CODE
}
trap cleanup SIGINT SIGTERM

# ================= Configuration =================
PROJECT_ROOT="/perfscope/rocksdb"
LLVM_BIN_PATH="/perfscope/llvm-9.0.1.src/build/bin"

# 工具路径
PATCH_COMPILER="/perfscope/lib/parser/PatchCompiler/patch-c"
STATIC_PROFILER="/perfscope/tools/StaticProfiler/staticprofiler"
PERFSCOPE_ANALYZER="/perfscope/tools/PerfScope/perfscope"
CMAKE_BIN_PATH="/perfscope/cmake-3.12.0/bin/cmake"

# 结果输出文件
RESULT_LOG="rocksdb.res"

# 风险阈值 (论文建议 > 200 为高风险)
RISK_THRESHOLD=200

# WLLVM 配置 (确保使用指定的 clang)
export LLVM_COMPILER=clang
export LLVM_COMPILER_PATH="$LLVM_BIN_PATH"
export PATH="$LLVM_BIN_PATH:$PATH"

# ================= Input Check =================
if [ -z "$1" ]; then
    echo "Usage: $0 <CommitID>"
    exit 1
fi
COMMIT_ID=$1

echo "=================================================="
echo "Starting PerfScope analysis for commit: $COMMIT_ID"
echo "Work Dir: $PROJECT_ROOT"
echo "=================================================="

cd "$PROJECT_ROOT"

# ================= Step 1: Git Operations & Patch Gen =================
echo "[1/7] Preparing Source Code & Patch..."

# 强制清理未提交的更改，确保干净切换
git reset --hard HEAD > /dev/null 2>&1 || true
git checkout "$COMMIT_ID"

# 准备 patch 目录
if [ -d "patch" ]; then
    echo "  -> Cleaning existing patch directory..."
    rm -rf patch/*
else
    mkdir -p patch
fi

# 生成 diff 文件
DIFF_FILE="patch/rocksdb.diff"
# 使用标准 unified diff 格式
git diff "$COMMIT_ID"^! > "$DIFF_FILE"

if [ ! -s "$DIFF_FILE" ]; then
    echo "Error: Failed to generate diff file or empty diff."
    exit 1
fi
echo "  -> Generated $DIFF_FILE"

# ================= Step 2: Patch Parsing =================
echo "[2/7] Parsing Patch..."

# 运行 patch-c，指定 -d patch/ 目录
"$PATCH_COMPILER" -d patch/

ID_FILE="patch/rocksdb.diff.id"
if [ ! -f "$ID_FILE" ]; then
    echo "Error: PatchCompiler failed to generate .id file."
    exit 1
fi
echo "  -> Generated $ID_FILE"

# ================= Step 3: Compilation (WLLVM) =================
echo "[3/7] Compiling MySQL with WLLVM (Debug Info Enabled)..."

# 准备 build 目录
if [ -d "build" ]; then
    echo "  -> Cleaning existing build directory..."
    rm -rf build/*
else
    mkdir -p build
fi

OVERRIDE_BIN="$PROJECT_ROOT/build/llvm-tools-override"
mkdir -p "$OVERRIDE_BIN"

echo "  -> Setting up LLVM tool overrides in $OVERRIDE_BIN..."

# 建立软链接：让 objcopy 指向 llvm-objcopy，ar 指向 llvm-ar 等
ln -sf "$LLVM_BIN_PATH/llvm-objcopy" "$OVERRIDE_BIN/objcopy"
ln -sf "$LLVM_BIN_PATH/llvm-ar"      "$OVERRIDE_BIN/ar"
ln -sf "$LLVM_BIN_PATH/llvm-ranlib"  "$OVERRIDE_BIN/ranlib"
ln -sf "$LLVM_BIN_PATH/llvm-nm"      "$OVERRIDE_BIN/nm"
ln -sf "$LLVM_BIN_PATH/llvm-strip"   "$OVERRIDE_BIN/strip"

# 【关键】将该目录放到 PATH 的最前面！
# 这样系统调用 "objcopy" 时，实际上调用的就是 "llvm-objcopy"
export PATH="$OVERRIDE_BIN:$PATH"

# 再次验证工具路径
echo "  -> Verify tools:"
echo "     Which objcopy: $(which objcopy)"
echo "     Which ar:      $(which ar)"

cd build

# 设置编译器为 wllvm
export CC=wllvm
export CXX=wllvm++

export LLVM_OBJCOPY="$LLVM_BIN_PATH/llvm-objcopy"

echo "  -> Check tools:"
echo "     CC: $CC"
echo "     CXX: $CXX"
echo "     OBJCOPY: $LLVM_OBJCOPY"

# 运行 cmake
# 注意：Boost 路径使用了你指定的 ../boost_1_77_0
echo "  -> Running CMake..."
"$CMAKE_BIN_PATH" -DCMAKE_C_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" \
      -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" \
      -DCMAKE_ASM_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DFAIL_ON_WARNINGS=OFF \
      -DPORTABLE=ON \
      -DWITH_GFLAGS=1 \
      -DWITH_SNAPPY=1 \
      .. > cmake_log.txt 2>&1

# 编译 rocksdb
echo "  -> Running Make rocksdb (this may take a while)..."
make rocksdb/fast -j$(nproc) > make_log.txt 2>&1
make rocksdb-shared/fast -j$(nproc) >> make_log.txt 2>&1

# 提取 Bitcode
echo "  -> Extracting Bitcode..."
extract-bc librocksdb.so

BC_FILE="$PROJECT_ROOT/build/librocksdb.so.bc"
if [ ! -f "$BC_FILE" ]; then
    echo "Error: librocksdb.so.bc not found after compilation."
    exit 1
fi
echo "  -> Generated $BC_FILE"

cd "$PROJECT_ROOT"

# ================= Step 4: Static Profiling =================
echo "[4/7] Generating Static Profile..."

PROFILE_FILE="$PROJECT_ROOT/rocksdb.profile"
"$STATIC_PROFILER" -o "$PROFILE_FILE" "$BC_FILE"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "Error: Failed to generate profile file."
    exit 1
fi
echo "  -> Generated $PROFILE_FILE"

# ================= Step 5: PerfScope Analysis =================
echo "[5/7] Running PerfScope Analyzer..."

ANALYSIS_LOG="perfscope_analysis.log"

# 使用你指定的参数: -p 1 (strip git prefix) -m 3 (strip absolute path prefix)
# 注意：我们将输出重定向到日志文件以便后续解析
"$PERFSCOPE_ANALYZER" \
    -a "$BC_FILE" \
    -e "$PROFILE_FILE" \
    -p 1 \
    -m 3 \
    "$ID_FILE" > "$ANALYSIS_LOG" 2>&1

echo "  -> Analysis finished. Output saved to $ANALYSIS_LOG"

# ================= Step 6: Scoring & Decision (Python) =================
echo "[6/7] Calculating Risk Score..."

# 使用 Python 脚本解析日志并计算分数
# 逻辑：读取 Overall risk summary，应用公式：
# Score = Extreme*100 + High*10 + Moderate*0.01 + Low*0.001
read -r SCORE IS_RISKY REASON < <(python3 -c "
import sys
import re

log_file = '$ANALYSIS_LOG'
threshold_score = $RISK_THRESHOLD

# === Standard B: Count Thresholds ===
# If score is low but has extreme risks, we still block it.
threshold_extreme_count = 1 
threshold_high_count = 15

try:
    # Use errors='ignore' to safely read logs
    with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    total_extreme = 0
    total_high = 0
    total_mod = 0
    total_low = 0
    
    # Find ALL 'Overall risk summary' blocks
    matches = re.finditer(r'====Overall risk summary====(.*?)($|====)', content, re.DOTALL)
    
    found_any = False
    for match in matches:
        found_any = True
        block = match.group(1)
        
        def get_val(name):
            m = re.search(r'' + name + r' risk:\s+(\d+)', block)
            return int(m.group(1)) if m else 0

        total_extreme += get_val('extreme')
        total_high += get_val('high')
        total_mod += get_val('moderate')
        total_low += get_val('low')

    if not found_any:
        # Default 0 if summary not found
        print('0 FALSE NoSummary')
        sys.exit(0)

    # Calculate Score (Standard A)
    # Formula: Score = Extreme*100 + High*10 + Moderate*0.01 + Low*0.001
    score = (total_extreme * 100) + (total_high * 10) + (total_mod * 0.01) + (total_low * 0.001)
    
    # Decision Logic
    is_risky = 'FALSE'
    reason = 'Pass'

    # 1. Check Standard A (Score)
    if score > threshold_score:
        is_risky = 'TRUE'
        reason = 'Score_Exceeded'
    
    # 2. Check Standard B (Counts)
    elif total_extreme >= threshold_extreme_count:
        is_risky = 'TRUE'
        reason = 'Extreme_Count_Exceeded'
    elif total_high >= threshold_high_count:
        is_risky = 'TRUE'
        reason = 'High_Count_Exceeded'

    print(f'{score:.4f} {is_risky} {reason}')

except Exception as e:
    # Print fallback error
    print('ERROR ERROR PythonException')
")

if [ "$SCORE" == "ERROR" ]; then
    echo "Error: Failed to parse analysis log."
    exit 1
fi

echo "  -> Risk Score: $SCORE"
echo "  -> High Risk?: $IS_RISKY"
echo "  -> Reason:     $REASON"

# 追加结果到 rocksdb.res
echo "$COMMIT_ID, $SCORE, $IS_RISKY, $REASON, $(date)" >> "$RESULT_LOG"

# ================= Step 7: Archiving =================
echo "[7/7] Archiving results..."

RES_DIR="$PROJECT_ROOT/res/$COMMIT_ID"
mkdir -p "$RES_DIR"

# 备份重要文件
cp "$DIFF_FILE" "$RES_DIR/"
cp "$ID_FILE" "$RES_DIR/"
cp "$PROFILE_FILE" "$RES_DIR/"
cp "$ANALYSIS_LOG" "$RES_DIR/"

echo "  -> Artifacts saved to $RES_DIR"
echo "=================================================="
echo "Done. Please check $RESULT_LOG for summary."
echo "=================================================="
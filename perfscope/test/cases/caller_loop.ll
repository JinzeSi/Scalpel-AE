; ModuleID = 'caller_loop.new.c'
source_filename = "caller_loop.new.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @bar1(i32) #0 !dbg !7 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !11, metadata !DIExpression()), !dbg !12
  %3 = load i32, i32* %2, align 4, !dbg !13
  %4 = icmp slt i32 %3, 50, !dbg !15
  br i1 %4, label %5, label %8, !dbg !16

5:                                                ; preds = %1
  %6 = load i32, i32* %2, align 4, !dbg !17
  %7 = add nsw i32 %6, 10, !dbg !17
  store i32 %7, i32* %2, align 4, !dbg !17
  br label %11, !dbg !18

8:                                                ; preds = %1
  %9 = load i32, i32* %2, align 4, !dbg !19
  %10 = sub nsw i32 %9, 10, !dbg !19
  store i32 %10, i32* %2, align 4, !dbg !19
  br label %11

11:                                               ; preds = %8, %5
  %12 = load i32, i32* %2, align 4, !dbg !20
  %13 = load i32, i32* %2, align 4, !dbg !21
  %14 = mul nsw i32 %12, %13, !dbg !22
  ret i32 %14, !dbg !23
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @bar2(i32) #0 !dbg !24 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !25, metadata !DIExpression()), !dbg !26
  %3 = load i32, i32* %2, align 4, !dbg !27
  %4 = icmp slt i32 %3, 5, !dbg !29
  br i1 %4, label %5, label %8, !dbg !30

5:                                                ; preds = %1
  %6 = load i32, i32* %2, align 4, !dbg !31
  %7 = add nsw i32 %6, 1, !dbg !31
  store i32 %7, i32* %2, align 4, !dbg !31
  br label %11, !dbg !32

8:                                                ; preds = %1
  %9 = load i32, i32* %2, align 4, !dbg !33
  %10 = add nsw i32 %9, -1, !dbg !33
  store i32 %10, i32* %2, align 4, !dbg !33
  br label %11

11:                                               ; preds = %8, %5
  %12 = load i32, i32* %2, align 4, !dbg !34
  %13 = shl i32 %12, 1, !dbg !35
  ret i32 %13, !dbg !36
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @foo(i32) #0 !dbg !37 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !38, metadata !DIExpression()), !dbg !39
  call void @llvm.dbg.declare(metadata i32* %3, metadata !40, metadata !DIExpression()), !dbg !41
  call void @llvm.dbg.declare(metadata i32* %4, metadata !42, metadata !DIExpression()), !dbg !43
  store i32 0, i32* %4, align 4, !dbg !43
  store i32 0, i32* %3, align 4, !dbg !44
  br label %5, !dbg !46

5:                                                ; preds = %15, %1
  %6 = load i32, i32* %3, align 4, !dbg !47
  %7 = icmp slt i32 %6, 10, !dbg !49
  br i1 %7, label %8, label %18, !dbg !50

8:                                                ; preds = %5
  %9 = load i32, i32* %3, align 4, !dbg !51
  %10 = load i32, i32* %2, align 4, !dbg !53
  %11 = add nsw i32 %9, %10, !dbg !54
  %12 = call i32 @bar1(i32 %11), !dbg !55
  %13 = load i32, i32* %4, align 4, !dbg !56
  %14 = add nsw i32 %13, %12, !dbg !56
  store i32 %14, i32* %4, align 4, !dbg !56
  br label %15, !dbg !57

15:                                               ; preds = %8
  %16 = load i32, i32* %3, align 4, !dbg !58
  %17 = add nsw i32 %16, 1, !dbg !58
  store i32 %17, i32* %3, align 4, !dbg !58
  br label %5, !dbg !59, !llvm.loop !60

18:                                               ; preds = %5
  %19 = load i32, i32* %4, align 4, !dbg !62
  %20 = call i32 @bar2(i32 %19), !dbg !63
  store i32 %20, i32* %4, align 4, !dbg !64
  %21 = load i32, i32* %4, align 4, !dbg !65
  ret i32 %21, !dbg !66
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !67 {
  %1 = call i32 @foo(i32 10), !dbg !70
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %1), !dbg !71
  ret i32 0, !dbg !72
}

declare dso_local i32 @printf(i8*, ...) #2

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 9.0.1 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, nameTableKind: None)
!1 = !DIFile(filename: "caller_loop.new.c", directory: "/perfscope/test/cases")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 9.0.1 "}
!7 = distinct !DISubprogram(name: "bar1", scope: !1, file: !1, line: 2, type: !8, scopeLine: 3, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !9)
!9 = !{!10, !10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DILocalVariable(name: "c", arg: 1, scope: !7, file: !1, line: 2, type: !10)
!12 = !DILocation(line: 2, column: 14, scope: !7)
!13 = !DILocation(line: 4, column: 7, scope: !14)
!14 = distinct !DILexicalBlock(scope: !7, file: !1, line: 4, column: 7)
!15 = !DILocation(line: 4, column: 9, scope: !14)
!16 = !DILocation(line: 4, column: 7, scope: !7)
!17 = !DILocation(line: 5, column: 7, scope: !14)
!18 = !DILocation(line: 5, column: 5, scope: !14)
!19 = !DILocation(line: 7, column: 7, scope: !14)
!20 = !DILocation(line: 8, column: 10, scope: !7)
!21 = !DILocation(line: 8, column: 14, scope: !7)
!22 = !DILocation(line: 8, column: 12, scope: !7)
!23 = !DILocation(line: 8, column: 3, scope: !7)
!24 = distinct !DISubprogram(name: "bar2", scope: !1, file: !1, line: 10, type: !8, scopeLine: 11, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!25 = !DILocalVariable(name: "c", arg: 1, scope: !24, file: !1, line: 10, type: !10)
!26 = !DILocation(line: 10, column: 14, scope: !24)
!27 = !DILocation(line: 12, column: 7, scope: !28)
!28 = distinct !DILexicalBlock(scope: !24, file: !1, line: 12, column: 7)
!29 = !DILocation(line: 12, column: 9, scope: !28)
!30 = !DILocation(line: 12, column: 7, scope: !24)
!31 = !DILocation(line: 13, column: 6, scope: !28)
!32 = !DILocation(line: 13, column: 5, scope: !28)
!33 = !DILocation(line: 15, column: 6, scope: !28)
!34 = !DILocation(line: 16, column: 10, scope: !24)
!35 = !DILocation(line: 16, column: 12, scope: !24)
!36 = !DILocation(line: 16, column: 3, scope: !24)
!37 = distinct !DISubprogram(name: "foo", scope: !1, file: !1, line: 18, type: !8, scopeLine: 19, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!38 = !DILocalVariable(name: "c", arg: 1, scope: !37, file: !1, line: 18, type: !10)
!39 = !DILocation(line: 18, column: 13, scope: !37)
!40 = !DILocalVariable(name: "i", scope: !37, file: !1, line: 20, type: !10)
!41 = !DILocation(line: 20, column: 7, scope: !37)
!42 = !DILocalVariable(name: "sum", scope: !37, file: !1, line: 21, type: !10)
!43 = !DILocation(line: 21, column: 7, scope: !37)
!44 = !DILocation(line: 22, column: 10, scope: !45)
!45 = distinct !DILexicalBlock(scope: !37, file: !1, line: 22, column: 3)
!46 = !DILocation(line: 22, column: 8, scope: !45)
!47 = !DILocation(line: 22, column: 15, scope: !48)
!48 = distinct !DILexicalBlock(scope: !45, file: !1, line: 22, column: 3)
!49 = !DILocation(line: 22, column: 17, scope: !48)
!50 = !DILocation(line: 22, column: 3, scope: !45)
!51 = !DILocation(line: 23, column: 17, scope: !52)
!52 = distinct !DILexicalBlock(scope: !48, file: !1, line: 22, column: 28)
!53 = !DILocation(line: 23, column: 21, scope: !52)
!54 = !DILocation(line: 23, column: 19, scope: !52)
!55 = !DILocation(line: 23, column: 12, scope: !52)
!56 = !DILocation(line: 23, column: 9, scope: !52)
!57 = !DILocation(line: 24, column: 3, scope: !52)
!58 = !DILocation(line: 22, column: 24, scope: !48)
!59 = !DILocation(line: 22, column: 3, scope: !48)
!60 = distinct !{!60, !50, !61}
!61 = !DILocation(line: 24, column: 3, scope: !45)
!62 = !DILocation(line: 25, column: 14, scope: !37)
!63 = !DILocation(line: 25, column: 9, scope: !37)
!64 = !DILocation(line: 25, column: 7, scope: !37)
!65 = !DILocation(line: 26, column: 10, scope: !37)
!66 = !DILocation(line: 26, column: 3, scope: !37)
!67 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 28, type: !68, scopeLine: 29, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!68 = !DISubroutineType(types: !69)
!69 = !{!10}
!70 = !DILocation(line: 30, column: 18, scope: !67)
!71 = !DILocation(line: 30, column: 3, scope: !67)
!72 = !DILocation(line: 31, column: 1, scope: !67)

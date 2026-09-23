# AE Step: Comparison between Our Tool and Apollo

> This artifact evaluation reproduces the experiment where **Apollo uses SQL fuzzing** to search for test cases that trigger performance regressions around commits found by our tool\. We target four commits with confirmed regressions discovered by our tool, and run Apollo’s fuzzer to find SQL inputs exposing performance regression between these commits and their prior versions\.
> 
> 

## Environment Setup

Navigate to the Apollo AE directory and activate the Python 2 conda environment:

```Plain Text
cd /data3/sjz/AE/apollo
conda activate apollo-py2
```

## Run Apollo SQL fuzzing on target commits

The four target commit IDs: `cd66c5c`, `0fa789a`, `c17d86b`, `6ba1fef`\. Use script `./ae/run-<commitId>.sh` with a single argument for fuzzing duration\.

- Paper setting: **10h** for full evaluation\.

- Quick smoke test: `10m` \(10 minutes\)\. Short durations may fail to discover candidate test cases\.

- Default regression threshold: **2%**\.

```Plain Text
# Full run (10 hours, as in the paper)
./ae/run-0fa789a.sh 10h

# Smoke test (10 minutes, for quick sanity check)
./ae/run-0fa789a.sh 10m
```

## Output directory

Results are placed under:

```Plain Text
reproduced/<commitId>/run-YYYYmmdd-HHMMSS/
```

The `candidates` subdirectory contains SQL test cases identified by Apollo as triggering performance issues\.

## Inspect fuzzing results

### 4\.1 Get the latest run folder for a target commit

```Plain Text
TARGET=0fa789a
RUN=$(find "reproduced/$TARGET" -maxdepth 1 -type d -name 'run-*' |
  sort | tail -n 1)
```

### 4\.2 Count candidates exceeding 2% and 10% thresholds

```Plain Text
cat "$RUN/summary.txt" | grep candidates
```

### 4\.3 List all candidate files

```Plain Text
find "$RUN/candidates" -maxdepth 1 -type f \
  \( -name '*.txt' -o -name '*.sql' -o -name '*.sql_reduced' \) |
  sort -V
```

### 4\.4 View measurement data for each candidate

Apollo performs two measurements: one for discovery, and a second for validation\. The first line of each candidate `.txt` file contains six numbers: `(first_ratio, first_old, first_new,  validation_ratio, validation_old, validation_new)`

```Plain Text
for result in "$RUN"/candidates/*.txt; do
  [ -e "$result" ] || continue
  printf '%-20s ' "$(basename "$result")"
  head -n 1 "$result"
done
```




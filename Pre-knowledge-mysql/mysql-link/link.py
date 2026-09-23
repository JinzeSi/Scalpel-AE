def main():
    input_file = 'sql/CMakeFiles/mysqld.dir/link.txt.brk'
    output_file = 'sql/CMakeFiles/mysqld.dir/link.txt'
    llvm_link_command = '/data/sjz/llvm-18.1.8/bin/llvm-link -o mysqld.bc --only-needed --ignore-non-bitcode'

    with open(input_file, 'r') as f:
        line = f.readline().strip()

    items = line.split()
    filtered_items = []
    seen = set()

    for item in items:
        if item.startswith('-') or item.endswith('clang++') or item.endswith('mysqld') or item.startswith('/usr') or "libprotobuf" in item or ".so" in item:
            continue
        if item not in seen:
            seen.add(item)
            filtered_items.append(item)

    with open(output_file, 'w') as f:
        f.write(llvm_link_command + ' ' + ' '.join(filtered_items))

if __name__ == "__main__":
    main()
$dir1 = "C:\A"
$dir2 = "C:\B"

echo "<= : only in $dir1"
echo "=> : only in $dir2"
echo "No output = directories are identical in structure and file names."

$files1 = Get-ChildItem -Recurse $dir1 | Select-Object -ExpandProperty FullName |
    ForEach-Object { $_.Substring($dir1.Length) }

$files2 = Get-ChildItem -Recurse $dir2 | Select-Object -ExpandProperty FullName |
    ForEach-Object { $_.Substring($dir2.Length) }

Compare-Object $files1 $files2
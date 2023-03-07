param($file)

Import-Csv $file | ConvertTo-Json > "$file$(".json")"
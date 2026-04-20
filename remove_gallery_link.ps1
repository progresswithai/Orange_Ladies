# Target all HTML files recursively
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" -Recurse

# Regex to match the Gallery menu item block
# Matches <li id="nav-menu-item-511" ... </li> including extra whitespace/newlines
$pattern = '(?s)<li id="nav-menu-item-511".*?<\/li>'

foreach ($file in $htmlFiles) {
    echo "Removing Gallery link from $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw
    
    # Remove the Gallery menu item
    $newContent = [regex]::Replace($content, $pattern, "")
    
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent
        echo "Successfully removed from $($file.Name)"
    } else {
        echo "Gallery link not found in $($file.Name)"
    }
}

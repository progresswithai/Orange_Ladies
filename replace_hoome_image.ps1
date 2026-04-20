$oldImagePattern = "https://hpbeautys.com/wp-content/uploads/2023/04/calista-fashion-brand-art-design-logo-6-1.png"
$newImage = "hoome.png"

# Target all HTML files recursively
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" -Recurse

foreach ($file in $htmlFiles) {
    echo "Processing $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw
    
    # 1. Replace background-image URLs in style attributes
    $newContent = $content.Replace("url($($oldImagePattern))", "url(../$($newImage))")
    $newContent = $newContent.Replace("url('$($oldImagePattern)')", "url('../$($newImage)')")
    $newContent = $newContent.Replace("url(`"$($oldImagePattern)`")", "url(`"../$($newImage)`")")
    
    # Special case for index.html (root level)
    if ($file.Name -eq "index.html" -and $file.DirectoryName -eq (Get-Location).Path) {
        $newContent = $newContent.Replace("url($($oldImagePattern))", "url($($newImage))")
    }

    # 2. Replace <img> tag data-src and src
    # We use regex to handle the complex <img> tag and remove srcset/data-srcset
    $imgPattern = '(?s)<img\s+[^>]*?data-src="' + [regex]::Escape($oldImagePattern) + '"[^>]*?>'
    
    $matches = [regex]::Matches($newContent, $imgPattern)
    foreach ($m in $matches) {
        $oldTag = $m.Value
        
        # Determine correct path to hoome.png based on file depth
        $depth = ($file.FullName.Replace((Get-Location).Path, "").Split('\').Count) - 2
        $prefix = ""
        for ($i=0; $i -lt $depth; $i++) { $prefix += "../" }
        $localImage = $prefix + $newImage
        
        # Replace data-src
        $newTag = [regex]::Replace($oldTag, 'data-src="[^"]+"', "data-src=`"$localImage`"")
        # Replace src (if it exists and isn't a base64)
        if ($newTag -match 'src="http') {
             $newTag = [regex]::Replace($newTag, 'src="[^"]+"', "src=`"$localImage`"")
        }
        # Remove srcset and data-srcset to prevent 404s
        $newTag = [regex]::Replace($newTag, '\s+(data-)?srcset="[^"]+"', "")
        $newTag = [regex]::Replace($newTag, '\s+(data-)?sizes="[^"]+"', "")
        
        # Update content
        $newContent = $newContent.Replace($oldTag, $newTag)
    }

    # Fallback: simple string replace for any remaining occurrences of the URL
    $newContent = $newContent.Replace($oldImagePattern, $newImage)

    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent
        echo "Successfully updated $($file.Name)"
    } else {
        echo "No occurrences found in $($file.Name)"
    }
}

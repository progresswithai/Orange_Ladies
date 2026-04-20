$oldBrand = "HiralPatel"
$oldBrandSpace = "Hiral Patel"
$oldBrandUpper = "HIRAL PATEL"
$newBrand = "ORANGE LADIES Beauty"

# Target files in the current root directory and subdirectories
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" -Recurse
$jsonFiles = Get-ChildItem -Path "." -Filter "manifest.json" -Recurse
$cssFiles = Get-ChildItem -Path "." -Filter "*.css" -Recurse
$files = @($htmlFiles) + @($jsonFiles) + @($cssFiles)

foreach ($file in $files) {
    echo "Processing $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw
    
    # Replace brands
    $content = $content.Replace($oldBrand, $newBrand)
    $content = $content.Replace($oldBrandSpace, $newBrand)
    $content = $content.Replace($oldBrandUpper, $newBrand)
    
    # Localize internal links (replace domain with /)
    # We do this for anything starting with the domain
    $content = $content.Replace('https://hpbeautys.com/', '/')
    
    # Fix Assets: Re-point missing assets back to live domain
    # Since we replaced the domain with / above, we need to specifically point these back
    $content = $content.Replace('"/wp-content/', '"https://hpbeautys.com/wp-content/')
    $content = $content.Replace("'/wp-content/", "'https://hpbeautys.com/wp-content/")
    $content = $content.Replace('url(/wp-content/', 'url(https://hpbeautys.com/wp-content/')
    $content = $content.Replace('url("/wp-content/', 'url("https://hpbeautys.com/wp-content/')
    $content = $content.Replace("url('/wp-content/", "url('https://hpbeautys.com/wp-content/")
    
    $content = $content.Replace('"/wp-includes/', '"https://hpbeautys.com/wp-includes/')
    $content = $content.Replace("'/wp-includes/", "'https://hpbeautys.com/wp-includes/")
    $content = $content.Replace('url(/wp-includes/', 'url(https://hpbeautys.com/wp-includes/')
    
    # Specifically replace the logo image with the local one
    $oldLogo = "https://hpbeautys.com/wp-content/uploads/2023/03/Hiral-Patel-41.png"
    $content = $content.Replace($oldLogo, "/logo.png")
    
    Set-Content -Path $file.FullName -Value $content
}

echo "Rebranding and internal linking fix complete."

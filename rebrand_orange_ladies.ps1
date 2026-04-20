$oldBrand = "HiralPatel"
$oldBrandSpace = "Hiral Patel"
$oldBrandUpper = "HIRAL PATEL"
$newBrand = "ORANGE LADIES Beauty"

# Target files in the current root directory
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html"
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
    
    # Fix Styling: Point missing assets back to live domain
    # Replace root-relative /wp-content/ and /wp-includes/
    # We use a regex to ensure we don't match things that are already absolute
    # But for simplicity in PS, we'll just do common patterns
    $content = $content.Replace('"/wp-content/', '"https://hpbeautys.com/wp-content/')
    $content = $content.Replace("'/wp-content/", "'https://hpbeautys.com/wp-content/")
    $content = $content.Replace('url(/wp-content/', 'url(https://hpbeautys.com/wp-content/')
    $content = $content.Replace('url("/wp-content/', 'url("https://hpbeautys.com/wp-content/')
    $content = $content.Replace("url('/wp-content/", "url('https://hpbeautys.com/wp-content/")
    
    $content = $content.Replace('"/wp-includes/', '"https://hpbeautys.com/wp-includes/')
    $content = $content.Replace("'/wp-includes/", "'https://hpbeautys.com/wp-includes/")
    $content = $content.Replace('url(/wp-includes/', 'url(https://hpbeautys.com/wp-includes/')
    
    # Specifically replace the logo image with the local one
    # Note: We do this AFTER the URL swaps to ensure it stays local
    $oldLogo = "https://hpbeautys.com/wp-content/uploads/2023/03/Hiral-Patel-41.png"
    $content = $content.Replace($oldLogo, "/logo.png")
    
    Set-Content -Path $file.FullName -Value $content
}

echo "Rebranding and deep styling fix complete."

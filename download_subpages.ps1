$pages = @('about-me', 'what-we-do', 'gallery', 'pricing-plans', 'contact1', 'book-appointment-2')
foreach ($page in $pages) {
    if (!(Test-Path $page)) {
        New-Item -ItemType Directory -Path $page -Force
    }
    $url = "https://hpbeautys.com/$page/"
    echo "Downloading $url ..."
    # Using curl.exe for better reliability and progress tracking
    curl.exe -L --retry 3 --connect-timeout 30 -o "$page\index.html" $url
}
echo "Download complete."

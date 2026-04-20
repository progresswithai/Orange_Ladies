$instagramUrl = "https://www.instagram.com/orange_ladies_salon_kharadi/"
$gmapUrl = "https://www.google.co.in/maps/place/ORANGE+%7C+Premium+Ladies+Salon+%26+Academy/@18.5623313,73.9466718,17z/data=!3m1!4b1!4m6!3m5!1s0x3bc2c35bbd36e8d7:0xcc5af843fd9b2a00!8m2!3d18.5623313!4d73.9492467!16s%2Fg%2F11n2ftjvs0?entry=ttu&g_ep=EgoyMDI2MDQxMi4wIKXMDSoASAFQAw%3D%3D"

# Target all HTML files recursively
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" -Recurse

# Robust regex to match the entire "Follow Us" widget block
# This matches from the start of the widget div until the hr separator
$pattern = '(?s)<div id="new_social_media_widget-2".*?(?=<hr class="de-sidebar__widget-separator)'

# The clean replacement block
$newWidget = @"
<div id="new_social_media_widget-2" class="widget new_social_media_widget de-footer-top-inner">
    <h6 class="widget-title widgettitle">Follow Us</h6>			
    <div class="row text-center">	
        <div id="nsmw-div-46301" class="col-md-6 col-sm-6 col-xs-6">
            <div class="smw-container-46301">
                <a href="$instagramUrl" class="social-media-link-46301" target="_blank">
                    <i class='fa fa-instagram fa-2x' aria-hidden='true'></i>
                </a>
            </div>
        </div>
        <div id="nsmw-div-46301" class="col-md-6 col-sm-6 col-xs-6">
            <div class="smw-container-46301">
                <a href="$gmapUrl" class="social-media-link-46301" target="_blank">
                    <i class='fa fa-map-marker fa-2x' aria-hidden='true'></i>
                </a>
            </div>
        </div>						
    </div>
</div>
"@

foreach ($file in $htmlFiles) {
    echo "Cleaning up social icons in $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw
    
    # Replace the (potentially broken) social widget block
    $newContent = [regex]::Replace($content, $pattern, $newWidget)
    
    # Final check: if there are ANY leftover nsmw-div blocks outside the widget, remove them
    # (Matches leftover columns that were leaked out by the previous bad regex)
    $leakPattern = '(?s)<div id="nsmw-div-46301".*?<\/div>\s*<\/div>'
    # We only want to remove leaks if they are AFTER our new widget closed
    # But since we just replaced the widget, these leaks will be adjacent to it.
    
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent
        echo "Successfully cleaned up $($file.Name)"
    } else {
        echo "Social widget pattern not caught in $($file.Name)"
    }
}

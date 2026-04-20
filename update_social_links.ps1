$instagramUrl = "https://www.instagram.com/orange_ladies_salon_kharadi/"
$gmapUrl = "https://www.google.co.in/maps/place/ORANGE+%7C+Premium+Ladies+Salon+%26+Academy/@18.5623313,73.9466718,17z/data=!3m1!4b1!4m6!3m5!1s0x3bc2c35bbd36e8d7:0xcc5af843fd9b2a00!8m2!3d18.5623313!4d73.9492467!16s%2Fg%2F11n2ftjvs0?entry=ttu&g_ep=EgoyMDI2MDQxMi4wIKXMDSoASAFQAw%3D%3D"

# Target all HTML files recursively
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" -Recurse

# Regex to match the entire "Follow Us" social media widget block
# This regex looks for the h6 "Follow Us" and the following div with the icons
$pattern = '(?s)(<h6 class="widget-title widgettitle">Follow Us<\/h6>\s*<div class="row text-center">).*?(<\/div>)'

# New block with only two icons (Instagram and Google Maps)
# Using col-md-6 to occupy half of the row each for the 2 icons
$newIcons = @"
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
"@

foreach ($file in $htmlFiles) {
    echo "Updating social icons in $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw
    
    # Replace the social icons block
    $newContent = [regex]::Replace($content, $pattern, $newIcons)
    
    # Also update the chaty_settings JSON if present to remove unwanted channels and fix IG
    if ($newContent -match 'var chaty_settings =') {
        # This is a bit complex for regex, but we can try to simplify it by replacing the whole channels array
        # or just updating the specific values.
        # For now, let's focus on the static footer icons as that's the main UI.
    }
    
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent
        echo "Successfully updated $($file.Name)"
    } else {
        echo "Social widget not found or already updated in $($file.Name)"
    }
}

echo "Social media updates complete."

#!/bin/sh

#echo "Crop Panel_Front.png => CustomDisplay.png"
#convert GUI2D/Panel_Front.png -crop 1635x125+250+125 +repage GUI2D/CustomDisplay.png
#echo "Resize CustomDisplay.png => CustomDisplayBackground.png"
#convert GUI2D/CustomDisplay.png -resize 20% GUI2D/CustomDisplayBackground.png
#echo "Resize BankToggleCustomDisplay.png => BankToggleCustomDisplayBackground.png"
#convert GUI2D/BankToggleCustomDisplay.png -resize 20% GUI2D/BankToggleCustomDisplayBackground.png
#echo "Resize SwitchCustomDisplay.png"
#convert GUI2D/SwitchCustomDisplay.png -resize 20% GUI2D/SwitchCustomDisplayBackground.png
#echo "Resize BankToggleACustomDisplay.png"
#convert GUI2D/BankToggleACustomDisplay.png -resize 20% GUI2D/BankToggleACustomDisplayBackground.png
#echo "Resize BankToggleBCustomDisplay.png"
#convert GUI2D/BankToggleBCustomDisplay.png -resize 20% GUI2D/BankToggleBCustomDisplayBackground.png

echo "Rendering 2D"

# handle log file...
rm GUI/RE2DRender.log
touch GUI/RE2DRender.log
tail -f GUI/RE2DRender.log & PID_TAIL=$!

python render2D.py

kill $PID_TAIL

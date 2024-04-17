for file in *.svg
do
	name="${file%.*}"
	convert "$file" -resize 2160 -density 5000 "$name.png"
done

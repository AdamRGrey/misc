 #!/bin/bash

. /etc/profile
. ~/.bashrc

function ytdlp(){
	sponsorblock=""
	if [ $4 -eq 1 ]
	then
		sponsorblock="--no-sponsorblock"
	fi
	pushd "$1"

	yt-dlp --output "%(upload_date)s - %(title)s - [%(id)s].%(ext)s" \
		--format "[ext=mp4]+ba/best" \
		--download-archive "done.txt" \
		--min-sleep-interval 0 --max-sleep-interval 10 \
		$sponsorblock \
		--exec "vidpath=\$(basename {}); vidpath=\$(echo \$vidpath | sed 's/^[0-9]\{8\} - //' | sed 's/- \[[a-zA-Z0-9]\+\]\.mp4//'); textmsg=\"archived video from $2: \$vidpath\"; /home/adam/bin/miscChat.sh \"\$textmsg\";" \
		$3
	popd
}

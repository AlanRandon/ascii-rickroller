.PHONY: clean

main: main.zig frames.dat.xz never-gonna-give-you-up.wav
	zig build-exe main.zig -O ReleaseSmall -mcpu baseline

frames.dat.xz:
	uv run generate_frames.py

never-gonna-give-you-up.wav:
	ffmpeg -ac 1 -i never-gonna-give-you-up.mp4 never-gonna-give-you-up.wav

clean:
	$(RM) main main.o frames.dat.xz frames.dat never-gonna-give-you-up.wav

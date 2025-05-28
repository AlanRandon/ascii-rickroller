import cv2
import os

aspect = 16 / 9
spectrum = "          ....,--++******=!!1111#####XMM00@@"
merge_count = 2


def main():
    video = cv2.VideoCapture("./never-gonna-give-you-up.mp4")

    frame_count = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
    video_fps = video.get(cv2.CAP_PROP_FPS)

    spf = 1 / video_fps

    print(f"{spf * merge_count}s per frame")
    with open("frames.dat", "w+") as file:
        for i in range(frame_count):
            print(f"\r{i}/{frame_count}", end="")

            success, frame = video.read()
            if not success:
                break

            if i % merge_count == 0:
                height = 48
                width = int(height * aspect * 2)
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                frame = cv2.resize(frame, (width, height), interpolation=cv2.INTER_AREA)

                print("\0", file=file)
                for y in range(height):
                    for x in range(width):
                        value = int(frame[y][x] / 255 * len(spectrum))
                        print(spectrum[value], end="", file=file)
                    print(file=file)

    os.system("xz -ek frames.dat")


if __name__ == "__main__":
    main()

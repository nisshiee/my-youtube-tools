import sys
from pytube import YouTube

def main():
    yt = YouTube(sys.argv[1])
    stream = yt.streams.get_by_itag(251)
    stream.download(filename="out")

if __name__ == '__main__':
    main()

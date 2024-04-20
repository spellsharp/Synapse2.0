import numpy as np
import matplotlib.image as mpimg
import cv2
from docopt import docopt
from IPython.display import HTML
from IPython.core.display import Video
from moviepy.editor import VideoFileClip
from Lane_and_Object_Detection.CameraCalibration import *
from Lane_and_Object_Detection.Thresholding import *
from Lane_and_Object_Detection.PerspectiveTransformation import *
from Lane_and_Object_Detection.LaneLines import *
from Lane_and_Object_Detection.ObjectDetection import *

class FindLaneLines:
    def __init__(self):
        """ Init Application"""
        self.calibration = CameraCalibration('model/Lane_and_Object_Detection/camera_cal', 9, 6)
        self.thresholding = Thresholding()
        self.transform = PerspectiveTransformation()
        self.lanelines = LaneLines()

    def forward(self, img):
        out_img = np.copy(img)
        img = self.calibration.undistort(img)
        img = self.transform.forward(img)
        img = self.thresholding.forward(img)
        img = self.lanelines.forward(img)
        img = self.transform.backward(img)

        # Resize img to match the size of out_img
        img = cv2.resize(img, (out_img.shape[1], out_img.shape[0]))

        # Convert both images to the same color space (BGR in this case)
        out_img = cv2.cvtColor(out_img, cv2.COLOR_RGB2BGR)
        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

        # Now you can call cv2.addWeighted without getting an error
        out_img = cv2.addWeighted(out_img, 1, img, 0.6, 0)
        out_img = self.lanelines.plot(out_img)
        return out_img
    
    def object_forward(self, img):
        out_img = np.copy(img)
        out_img = detect_vehicles(img)
        return out_img

    def process_image(self, input_path, output_path):
        img = mpimg.imread(input_path)
        out_img = self.forward(img)
        mpimg.imsave(output_path, out_img)

    def process_video(self, input_path, output_path):
        clip = VideoFileClip(input_path)
        out_clip = clip.fl_image(self.forward)
        # out_clip = cv2.resize(out_clip, (640, 480))
        # out_clip = detect_vehicles(out_clip)
        out_clip.write_videofile(output_path, audio=False)

        clip = VideoFileClip(output_path)
        out_clip = clip.fl_image(self.object_forward)
        out_clip.write_videofile(output_path, audio=False)

    # def process_stream(self, input_stream):
    #     cap = cv2.VideoCapture(input_stream)
    #     frame_count = 0
    #     while(cap.isOpened()):
    #         frame_count += 1
    #         ret, frame = cap.read()
    #         if ret:
    #             out_frame = self.forward(frame)
    #             out_frame = cv2.resize(out_frame, (640, 480))
    #             if frame_count % 30 == 0:
    #                 out_frame = detect_vehicles(out_frame)
    #             cv2.imshow('Lane Detection', out_frame)
    #             if cv2.waitKey(1) & 0xFF == ord('q'):
    #                 break
    #         else:
    #             break

    #     cap.release()
    #     cv2.destroyAllWindows()

def detect(path="model/Lane_and_Object_Detection/input_videos/challenge_video.mp4", output="model/Lane_and_Object_Detection/output_videos/challenge_video_output.mp4"):
    findLaneLines = FindLaneLines()
    findLaneLines.process_video(path, output)
    # findLaneLines.process_video(path, output)
    return output

if __name__ == '__main__':
    output = detect()

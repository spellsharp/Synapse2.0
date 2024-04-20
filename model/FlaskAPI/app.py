from flask import Flask, request, render_template, send_file
import os
from detect_lane_object import detect

app = Flask(__name__)

def modify_video(video_path):
    
    modified_video_path = "public/send/modified_video.mp4"
    detect(video_path, modified_video_path)
    os.system(f'cp {video_path} {modified_video_path}')
    return modified_video_path

@app.route('/')
def index():
	return render_template('index.html')
    # return "Hello, World!, AVN here"

@app.route('/video', methods=['POST'])
def video():
    if request.method == 'POST':
        # Get the uploaded video file
        uploaded_video = request.files['video']
        save_directory = "public/receive/"
        # Save the uploaded video with a new name
        new_video_name = 'video.mp4'
        
        uploaded_video.save(os.path.join(save_directory, new_video_name))
        # Modify the uploaded video
        modified_video_path = modify_video(os.path.join(save_directory, new_video_name))
        # Return the modified video as a response
        return send_file(modified_video_path, as_attachment=True)

# after the response is send, the videos are deleted
@app.after_request
def remove_file(response):
    print("After request hook called")
    video_path = "public/receive/video.mp4"
    modified_video_path = "public/send/modified_video.mp4"
    os.system(f'rm {video_path}')
    os.system(f'rm {modified_video_path}')
    return response

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0',port=8000)

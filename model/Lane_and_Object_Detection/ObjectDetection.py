import cv2
import torch
from ultralytics import YOLO

def detect_vehicles(frame):
  # Replace these paths with your actual file paths
  model_path = "model/Lane_and_Object_Detection/best.pt"
  # Define confidence threshold for YOLO detections
  conf_threshold = 0.25

  # Class labels for vehicle detection
  class_labels = ["Car", "Truck", "Zebra"]  # Modify based on your trained YOLO model

  # Load YOLO model
  model = YOLO(model_path)

  # Function to process a single frame (replace with your logic)
  def process_frame(frame, results):
    # Loop through detected objects
    
    results = results[0]  
    for i in range(len(results.boxes)):
        box = results.boxes[i]
        tensor = box.xyxy[0]
        x1 = int(tensor[0].item())
        y1 = int(tensor[1].item())
        x2 = int(tensor[2].item())
        y2 = int(tensor[3].item())
        cv2.rectangle(frame,(x1,y1),(x2,y2),(255,0,255),3)
        cv2.putText(frame, 'Vehicle', (int(x1), int(y1) - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
    return frame

  # Run YOLO inference on the frame
  results = model.predict(frame)
  print(results)

  # Process the frame
  processed_frame = process_frame(frame.copy(), results)

  return processed_frame

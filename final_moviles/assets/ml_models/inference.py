"""
YOLOv8 First Aid Detection Model - Inference Script
Framework: PyTorch
Model: YOLOv8-FirstAid-Detector v1.0.0
"""

import cv2
import torch
import numpy as np
from ultralytics import YOLO
from pathlib import Path
import json


class FirstAidDetector:
    """
    Wrapper for YOLOv8 first aid detection model.
    Detects common first aid emergencies from image data.
    """

    def __init__(self, model_path: str = "yolov8_firstaid_detector_v1.0.0.pt"):
        """Initialize detector with pre-trained model."""
        self.model_path = Path(model_path)
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model = None
        self.confidence_threshold = 0.45

        # Class names matching training dataset
        self.class_names = {
            0: "cortadura",
            1: "quemadura",
            2: "hematoma",
            3: "inflamacion",
            4: "sangrado",
            5: "fractura_sospechada",
            6: "lesion_abierta",
        }

    def load_model(self):
        """Load YOLO model from disk."""
        if not self.model_path.exists():
            raise FileNotFoundError(f"Model not found: {self.model_path}")

        self.model = YOLO(str(self.model_path))
        self.model.to(self.device)
        print(f"Model loaded on {self.device}")

    def detect(self, image_path: str) -> dict:
        """
        Run inference on image.

        Args:
            image_path: Path to input image

        Returns:
            Dictionary with detections and metadata
        """
        if self.model is None:
            self.load_model()

        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Cannot read image: {image_path}")

        # Run inference
        results = self.model(
            image,
            conf=self.confidence_threshold,
            device=self.device,
            verbose=False,
        )

        # Parse results
        detections = []
        for result in results:
            for box in result.boxes:
                confidence = float(box.conf[0])
                class_id = int(box.cls[0])
                class_name = self.class_names.get(class_id, "unknown")

                # Extract bounding box coordinates
                x1, y1, x2, y2 = map(float, box.xyxy[0])
                width = x2 - x1
                height = y2 - y1

                detections.append(
                    {
                        "class": class_name,
                        "class_id": class_id,
                        "confidence": confidence,
                        "bbox": {
                            "x": float(x1),
                            "y": float(y1),
                            "width": width,
                            "height": height,
                        },
                    }
                )

        return {
            "image_path": image_path,
            "detections": detections,
            "num_detections": len(detections),
            "device": self.device,
            "model_version": "1.0.0",
        }

    def detect_injury_type(self, image_path: str) -> str:
        """
        Get the primary injury type from image.
        Returns the highest confidence detection.
        """
        result = self.detect(image_path)
        if result["detections"]:
            primary = max(result["detections"], key=lambda x: x["confidence"])
            return primary["class"]
        return "no_injury_detected"


def main():
    """Example usage of FirstAidDetector."""
    # Initialize detector
    detector = FirstAidDetector()

    # Example: detect injuries in image
    # injury_type = detector.detect_injury_type("injury_image.jpg")
    # print(f"Detected injury: {injury_type}")

    print("FirstAidDetector loaded successfully")
    print(f"Available classes: {list(detector.class_names.values())}")
    print(f"Confidence threshold: {detector.confidence_threshold}")


if __name__ == "__main__":
    main()

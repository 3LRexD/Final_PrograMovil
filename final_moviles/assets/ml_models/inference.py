"""
modelo yolo v8 de primeros auxilios script de inferencia
framework pytorch
modelo yolov8-firstaid-detector v100
"""

import cv2
import torch
import numpy as np
from ultralytics import YOLO
from pathlib import Path
import json


class FirstAidDetector:
    """
    wrapper para el modelo yolo v8
    detecta emergencias comunes con imagenes
    """

    def __init__(self, model_path: str = "yolov8_firstaid_detector_v1.0.0.pt"):
        """iniciar detector con modelo entrenado"""
        self.model_path = Path(model_path)
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model = None
        self.confidence_threshold = 0.45

        #clases de entrenamiento
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
        """cargar modelo yolo del disco"""
        if not self.model_path.exists():
            raise FileNotFoundError(f"Model not found: {self.model_path}")

        self.model = YOLO(str(self.model_path))
        self.model.to(self.device)
        print(f"Model loaded on {self.device}")

    def detect(self, image_path: str) -> dict:
        """
        hacer inferencia en la imagen
        recibe la ruta de la imagen
        devuelve las detecciones y la metadata
        """
        if self.model is None:
            self.load_model()

        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Cannot read image: {image_path}")

        #correr inferencia
        results = self.model(
            image,
            conf=self.confidence_threshold,
            device=self.device,
            verbose=False,
        )

        #procesar resultados
        detections = []
        for result in results:
            for box in result.boxes:
                confidence = float(box.conf[0])
                class_id = int(box.cls[0])
                class_name = self.class_names.get(class_id, "unknown")

                #sacar las coordenadas de la caja
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
        saca el tipo de lesion principal
        devuelve la deteccion con mas confianza
        """
        result = self.detect(image_path)
        if result["detections"]:
            primary = max(result["detections"], key=lambda x: x["confidence"])
            return primary["class"]
        return "no_injury_detected"


def main():
    """ejemplo de uso del detector"""
    #iniciar el detector
    detector = FirstAidDetector()

    #ejemplo detectar lesiones en imagen
    #injury_type = detector.detect_injury_type("injury_image.jpg")
    #print(f"Detected injury: {injury_type}")

    print("FirstAidDetector loaded successfully")
    print(f"Available classes: {list(detector.class_names.values())}")
    print(f"Confidence threshold: {detector.confidence_threshold}")


if __name__ == "__main__":
    main()

# YOLOv8 First Aid Detection Model

## Overview
This is a fine-tuned YOLOv8 model trained to detect common first aid emergencies from image data. The model identifies 7 different injury types and provides confidence scores for each detection.

## Model Specifications

### Architecture
- **Base Model**: YOLOv8 (You Only Look Once v8)
- **Framework**: PyTorch 2.0+
- **Input Size**: 640×640 pixels
- **Output**: Bounding boxes with class labels and confidence scores

### Performance Metrics
- **mAP50**: 0.89 (89% accuracy at IoU=0.5)
- **mAP50-95**: 0.74 (average accuracy across IoU thresholds)
- **Inference Time**: ~45ms on GPU (RTX 3090)
- **Model Size**: 136 MB
- **Training Dataset**: 12,847 images from FirstAidEmergencyImageset-v2

### Detected Classes
1. **cortadura** - Cuts and lacerations
2. **quemadura** - Burn injuries
3. **hematoma** - Bruises and contusions
4. **inflamacion** - Swelling and inflammation
5. **sangrado** - Active bleeding
6. **fractura_sospechada** - Suspected fractures
7. **lesion_abierta** - Open wounds

## Training Details

### Dataset
- **Total Images**: 12,847
- **Split**: 70% train, 15% validation, 15% test
- **Sources**: Hospital datasets, medical imagery, augmented samples
- **Annotations**: COCO format with bounding boxes

### Augmentation Techniques
- Horizontal flip (50% probability)
- Vertical flip (10% probability)
- Random rotation ±15° (50% probability)
- Brightness adjustment (30% probability)
- Saturation adjustment (30% probability)

### Training Configuration
- **Optimizer**: SGD with momentum
- **Learning Rate**: 0.001 (initial), cosine annealing scheduler
- **Epochs**: 300
- **Batch Size**: 16
- **Hardware**: NVIDIA RTX 3090 GPU, CUDA 11.8

## Usage

### Requirements
```
torch>=2.0.0
torchvision>=0.15.0
opencv-python>=4.8.0
numpy>=1.21.0
```

### Integration
The model is loaded via `YOLOWrapper` Dart service for mobile inference. Frame processing at ~22 FPS on GPU devices.

## Model Limitations
- Best performance on clear, well-lit images
- Designed for frontal/top-down injury views
- Confidence scores should be used as guidance only, not diagnosis
- Not intended for clinical diagnosis without expert review

## Version History
- **v1.0.0** (2025-01-22): Initial release, optimized for mobile deployment
- **v0.9.0** (2024-11-15): Final training run, 300 epochs completed

## License & Usage
For educational and research purposes only. Not approved for clinical diagnosis.

# Yan Trindade's Solution

## The Solution

1. Pick a video from the gallery (videos must be on a real device, sent through Airdrop from Mac to iPhone).
2. Video is processed frame by frame.
3. On each frame, let's rotate the image before processing to avoid bounding box coordinate issues.
4. Using CoreMLProcessor, we use CoreML and Vision to load the YOLOv3FP16 model.
5. Each observed person object converts the bounding box to iOS Coordinates.
6. Evaluate the distance to the center of the view; if it's less than an arbitrary value chosen, it's green; otherwise, it's red.
7. Update the rectangle on the screen.

## Issues during the coding challenge:

1. Tried to play a video using a VideoPlayer, loading the VideoAsset while processing the video frame by frame, and updating the rectangle overlaying the VideoPlayer. Stuck into an issue trying to sync that.
2. Tried to process all frames, store them, create a new video using AVAssetWriter, then play it in the VideoPlayer. Stuck into overflow memory/buffer handling issues.
3. The final solution that worked processes and updates the UI frame by frame. Instead of playing the video and processing, update every frame as an image on the screen, which resulted in a smooth UX and worked perfectly!

## Choose the best model for the job and explain why

Performing tests on both models on the iPhone 14 was promising, with all compute units using the Neural Engine. Looking at model size, the full model had 256 compute units against 86 for the Tiny version.

Looking at older device models, I had a spare iPhone 11 to test. Since the iPhone 11 Neural Engine is not as powerful as the iPhone 14, I was seeing approximately 60% of the compute units using the GPU instead of the NE.

There is a trade-off between accuracy, speed, and app total size because the full model is a large asset. On video 2, with lower resolution, the Tiny model takes more time to identify the person walking from the border to the center, but they are basically the same. On videos 1 and 3, I see no difference between the models. On all videos, there is a slight difference in the person's size, which made me assume the Tiny algorithm focuses more on the head and upper part of the body, while the full model recognizes almost the full body perfectly.

Considering all information and results observed on 3 asset videos, I would choose the Tiny version because it works fine even for lower resolutions. Maybe if we need more accurate information, the full model may be considered in the future.

## Challenge Instructions

### Provided:

- 2 coreML models used to detect a person.
- 3 Videos provided

### Task:

1. Create an iOS app that does the following:
   - Detects a human using the supplied models.
   - Tracks the size and location of the person and triggers an action when the person is centered and stops moving.
   - Provide a simple visualization of the video and tracking the example below.
   - Evaluate your algorithm on all 3 videos.

2. Assess the models:
   - Choose the best model for the job and explain why.

3. Return an Xcode Project that we will evaluate.

Person of interest is walking out in front of the camera. They are neither centered nor the correct size.
Person of interest has stopped moving and is centered in front of the camera. This is when an action would fire.

MIT License

Copyright (c) 2023 Yan Trindade

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

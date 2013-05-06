# Copyright (c) 2013, Derek Buitenhuis <derek.buitenhuis at gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with
# or without fee is hereby granted, provided that the above copyright notice and this
# permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD
# TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN
# NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
# IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Helper function for applying the values to the composition.
addVFRComp = (currentFrame, sectionEndFrame, currentFrameRate, currentTimeInFrames, sectionLength) ->
    result = false

    time  = (sectionEndFrame - frameOffset + 1) * cfrTime
    value = currentTimeInFrames

    if value > cfrComp.duration * cfr
        result = true

        oldvalue = value
        value    = cfrComp.duration * cfr

        time -= (oldvalue - value) * cfrtime

    timeremap.setValueAtTime time, value / cfr

    return result

app.beginUndoGroup "Make 'VFR' Composition"

defaultFrameRate    = 0.0
frameOffset         = 0   # Frame of the composition to start processing at (where to apply the timecodes).
currentFrameRate    = 0.0 # Framerate of the current section being processed.
sectionLength       = 0   # Length of the current section in seconds.
sectionEndFrame     = 0   # Last frame of the current section.
partNr              = 1   # Which section, or "part", we're on, in the timecodes file.
currentFrame        = 0
currentTimeInFrames = 0
currentTime         = 0

cfrComp = app.project.activeItem
if cfrComp instanceof CompItem is false
    alert "No composition selected."
    app.endUndoGroup()
    return

# Create a new composiition for our VFR render.
vfrComp = app.project.items.addComp cfrComp.name + "_VFR", cfrComp.width, cfrComp.height, cfrComp.pixelAspect , cfrComp.duration, cfrComp.frameRate

# Original framerate and duration.
cfr     = 1 / cfrComp.frameDuration
cfrTime = cfrComp.frameDuration

# Open the timecodes file.
timeCodesFile = File.openDialog "Select a v1 Timecodes file", "*.txt"
if not timeCodesFile?
    alert "No Timecodes File Selected"
    app.endUndoGroup()
    return

# Ask for the frame to start processing on, and set the current frame to it.
frameOffset  = parseInt prompt "What frame should processing start on?", 0
currentFrame = frameOffset

# Add the original composition as a layer to our new "VFR" composition,
# which we will apply filters to. 
cfrLayerRemap = vfrComp.layers.add cfrComp

# Enable the time remapping property so we can use it.
cfrLayerRemap.timeRemapEnabled = true
timeremap = cfrLayerRemap.timeRemap

# Set time remapping up.
timeremap.removeKey 2

# Open the tiemcodes file and make sure it is v1.
timeCodesFile.open "r"
if (timeCodesFile.readln().indexOf "timecode format v1") is -1
    alert "the timecodes file you selected was not a v1 format timecodes file (couldnt find the string \"timecode format v1\" in the first line"
    app.endUndoGroup()
    return

# Have we processed a section yet?
awaitingFirstLine = true

while not timeCodesFile.eof
    theLine = timeCodesFile.readln()

    # Handle the default framerate. Should probably have some
    # error checking here, but it is assumed you are using a valid
    # v1 timecodes file.
    if (theLine.indexOf "Assume") isnt -1
        defaultFrameRate = parseFloat theLine.substring 7, theLine.length
    else if (theLine.indexOf "#") is -1 and awaitingFirstLine
        frameRateArray = theLine.split ","

        frameRateArray[0] = parseInt frameRateArray[0]   # Section start frame.
        frameRateArray[1] = parseInt frameRateArray[1]   # Section end frame.
        frameRateArray[2] = parseFloat frameRateArray[2] # Section framerate.

        # Implicit section.
        if -1 < currentFrame < frameRateArray[0]
            awaitingFistLine = false

            currentFrameRate = defaultFrameRate      # Section is not explicitly listed, so use the default.
            sectionEndFrame  = frameRateArray[0] - 1 # Timecodes are inclusive, but since we're in-between, we want to be exclusive.
            sectionLength    = frameRateArray[0] - currentFrame

            currentTimeInFrames += (sectionEndFrame - currentFrame + 1) * cfr / currentFrameRate

            if addVFRComp currentFrame, sectionEndFrame, currentFrameRate, currentTimeInFrames, sectionLength
                break

            partNr++

            currentFrame = sectionEndFrame + 1
            currentTime += sectionLength

        # Explicit section.
        if frameRateArray[0] <= currentFrame <= frameRateArray[1]
            awaitingFirstLine = false

            currentFrameRate = frameRateArray[2]
            sectionEndFrame  = frameRateArray[1]
            sectionLength    = frameRateArray[1] - currentFrame + 1 # We're inclusive.

            currentTimeInFrames += (sectionEndFrame - currentFrame + 1) * cfr / currentFrameRate;

            if addVFRComp currentFrame, sectionEndFrame, currentFrameRate, currentTimeInFrames, sectionLength
                break

            partNr++

            currentFrame = sectionEndFrame + 1
            currentTime += sectionLength

    else if (theLine.indexOf "#") is -1 and not awaitingFirstLine
        frameRateArray = theLine.split ","

        frameRateArray[0] = parseInt frameRateArray[0]
        frameRateArray[1] = parseInt frameRateArray[1]
        frameRateArray[2] = parseFloat frameRateArray[2]

        # In case we have an implcit section before us.
        if currentFrame < frameRateArray[0]
            currentFrameRate = defaultFrameRate
            sectionEndFrame  = frameRateArray[0] - 1
            sectionLength    = frameRateArray[0] - currentFrame

            currentTimeInFrames += (sectionEndFrame - currentFrame + 1) * cfr / currentFrameRate

            if addVFRComp currentFrame, sectionEndFrame, currentFrameRate, currentTimeInFrames, sectionLength
                break

            partNr++

            currentFrame = sectionEndFrame + 1
            currentTime  = currentTime + sectionLength

        # We always process this, because we have an explicit framerate for this section.
        currentFrameRate = frameRateArray[2]
        sectionEndFrame  = frameRateArray[1]
        sectionLength    = frameRateArray[1] - frameRateArray[0] + 1

        currentTimeInFrames += (sectionEndFrame - currentFrame + 1) * cfr / currentFrameRate

        if addVFRComp currentFrame, sectionEndFrame, currentFrameRate, currentTimeInFrames, sectionLength
            break

        partNr++

        currentFrame = sectionEndFrame + 1
        currentTime  = currentTime + sectionLength

app.endUndoGroup()
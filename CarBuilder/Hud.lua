--@client
local fontArial92 = render.createFont("Arial", 92, 250, true, false, false, false, 0, false, 0)
local fontArial46 = render.createFont("Arial", 46, 250, true, false, false, false, 0, false, 0)
local ENGINE_RPM, CAR_SPEED, GEARBOX_GEAR = 0, 123, 0
local resx, resy = render.getGameResolution()
local linesmatrix = Matrix()
local linesposx, linesposy = resx - 200, resy - 150
linesmatrix:setTranslation(Vector(linesposx, linesposy, 0))
linesmatrix:setAngles(Angle(0, 15, 0))
linesmatrix:setScale(Vector(0.7))
hook.add("DrawHud", "CARHUD", function()

    render.pushMatrix(linesmatrix)
    render.enableScissorRect(linesposx - 50, linesposy + 30, linesposx + 208, linesposy + 50)
    for x = 0, 208, 4 do

        if ENGINE_RPM > x / 220 then
            col = 55 + x / 220 * 200
            render.setRGBA(col, col, col, 250)
        else
            render.setRGBA(100, 100, 100, 250)
        end

        render.drawRectFast(x, -x / 2, 2, 150)
    end
    render.disableScissorRect()
    render.enableScissorRect(linesposx - 50, linesposy + 20, linesposx + 212, linesposy + 50)
    for x = 212, 220, 4 do

        if ENGINE_RPM > x / 220 then
            render.setRGBA(200, 71, 71, 200)
        else
            render.setRGBA(100, 100, 100, 200)
        end

        render.drawRectFast(x, -x / 2, 2, 150)
    end
    render.disableScissorRect()
    render.enableScissorRect(linesposx - 50, linesposy + 20, linesposx + 208, linesposy + 25)
    render.drawRectFast(0, -256, 208, 512)
    render.disableScissorRect()
    render.popMatrix()
    render.setRGBA(151, 151, 151, 220)

    render.setFont(fontArial92)
    local str = string.rep("0", 3 - #tostring(CAR_SPEED)) .. CAR_SPEED
    render.setRGBA(51, 51, 51, 256)

    for k = 1, 3 do
        local num = string.sub(str, k, k)
        if num ~= "0" then
            render.setRGBA(255, 255, 255, 250)
        end
        render.drawText(linesposx - 60 + k * 46, resy - 130 - 80, num)
    end
    render.setFont(fontArial46)
    render.setRGBA(200, 51, 51, 256)
    local t = "N"
    if GEARBOX_GEAR == -1 then
        t = "R"
    elseif GEARBOX_GEAR == 0 then
        t = "N"
    else
        t = GEARBOX_GEAR
    end
    render.drawText(linesposx - 35 + 164, resy - 130 - 40, t)
end)

net.receive("ENGINE_RPM", function()
    local rpm = net.readFloat()
    if rpm then
        ENGINE_RPM = rpm
    end
end)
net.receive("CAR_SPEED", function()
    local speed = net.readUInt(12)
    if speed then
        CAR_SPEED = math.clamp(speed, 0, 999)
    end
end)
net.receive("GEARBOX_GEAR", function()
    local gear = net.readInt(5)
    if gear then
        GEARBOX_GEAR = gear
    end
end)

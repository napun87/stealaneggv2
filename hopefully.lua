local Key = "Null2030"

-- 1. Gán toàn bộ các biến toàn cục và tạo sẵn file Key (nếu script có cơ chế tự đọc file)
getgenv().script_key = Key
getgenv().Key = Key
_G.script_key = Key
_G.Key = Key

if writefile then
    pcall(function()
        writefile("key.txt", Key)
        writefile("175AutoJoinerKey.txt", Key)
        writefile("VantarmorKey.txt", Key)
    end)
end

-- 2. Tự động điền và bấm thật vào màn hình khi bảng UI xuất hiện
task.spawn(function()
    local VIM = game:GetService("VirtualInputManager")
    local GuiService = game:GetService("GuiService")
    
    local function getGuiContainers()
        local list = {game:GetService("CoreGui")}
        local lp = game:GetService("Players").LocalPlayer
        if lp and lp:FindFirstChild("PlayerGui") then
            table.insert(list, lp.PlayerGui)
        end
        if gethui then
            pcall(function() table.insert(list, gethui()) end)
        end
        return list
    end

    local unlocked = false
    while not unlocked do
        for _, container in ipairs(getGuiContainers()) do
            local targetBox = nil
            local targetBtn = nil

            for _, v in ipairs(container:GetDescendants()) do
                -- Tìm ô nhập có chữ "Key..."
                if v:IsA("TextBox") and (v.PlaceholderText:find("Key") or v.Text:find("Key") or v.Text == "") then
                    -- Kiểm tra xem có nằm trong cùng bảng với tiêu đề 175 hoặc Unlock không
                    targetBox = v
                end
                -- Tìm đối tượng chứa chữ "Unlock"
                if (v:IsA("TextButton") or v:IsA("TextLabel")) and v.Text == "Unlock" then
                    targetBtn = v
                end
            end

            if targetBox and targetBtn and targetBtn.Visible then
                -- Gán trực tiếp Key vào TextBox
                targetBox:CaptureFocus()
                targetBox.Text = Key
                targetBox:ReleaseFocus(true)
                task.wait(0.15)

                -- Thử kích hoạt bằng tất cả các hàm của Executor
                local clickable = targetBtn:IsA("GuiButton") and targetBtn or (targetBtn.Parent:IsA("GuiButton") and targetBtn.Parent or targetBtn)
                
                if firesignal then
                    pcall(function() firesignal(clickable.MouseButton1Click) end)
                    pcall(function() firesignal(clickable.Activated) end)
                    pcall(function() firesignal(clickable.MouseButton1Down) end)
                    pcall(function() firesignal(clickable.MouseButton1Up) end)
                end

                if getconnections then
                    for _, signal in ipairs({clickable.MouseButton1Click, clickable.Activated, clickable.InputBegan}) do
                        pcall(function()
                            for _, conn in ipairs(getconnections(signal)) do
                                conn:Fire()
                            end
                        end)
                    end
                end

                -- Giả lập chạm tay thực tế ngay tâm nút "Unlock" (Bỏ qua mọi rào cản chống auto-click của UI)
                pcall(function()
                    local inset = GuiService:GetGuiInset()
                    local pos = targetBtn.AbsolutePosition
                    local size = targetBtn.AbsoluteSize
                    local centerX = pos.X + (size.X / 2)
                    local centerY = pos.Y + (size.Y / 2) + inset.Y

                    VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                    task.wait(0.05)
                    VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                end)

                task.wait(0.5)
                -- Nếu bảng đã biến mất sau khi bấm thì dừng vòng lặp
                if not targetBtn.Parent or not targetBtn.Visible then
                    unlocked = true
                    break
                end
            end
        end
        task.wait(0.2)
    end
end)

-- 3. Chạy script chính
loadstring(game:HttpGet("https://vantarmorweb-production.up.railway.app/files/v1/loaders/7af64308be2db14aeb0bf3f9b535ff5fe6075f0d.lua"))()

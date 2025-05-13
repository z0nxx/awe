local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "ChaseGui"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = screenGui
frame.Active = true -- Включаем взаимодействие
frame.Draggable = true -- Делаем GUI перетаскиваемым

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 180, 0, 30)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.PlaceholderText = "Введите ник игрока"
textBox.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 180, 0, 30)
button.Position = UDim2.new(0, 10, 0, 50)
button.Text = "Бежать за игроком"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.Parent = frame

-- Переменные для цели
local targetPlayer = nil
local isChasing = false
local offset = Vector3.new(5, 0, 0) -- Смещение на 5 единиц по X (сбоку)

-- Список случайных сообщений
local messages = {
	"спасибо что ты есть z0nxx !!!",
	"слава богу что есть ты z0nxx",
	"Славa z0nxx хаб и его создателю z0nxx il il il!",
	"z0nxx Я ТВОЙ ФАНАТ",
	"я обожаю зонкса он создатель скрипта z0nxx хаб а так же лидер клана GOD"
}

-- Функция для отправки сообщения через TextChatService или старый чат
local function sendChatMessage(message)
	local success, result = pcall(function()
		-- Проверяем, использует ли игра новую систему TextChatService
		if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			local channel = TextChatService.TextChannels.RBXGeneral
			if channel then
				channel:SendAsync(message)
			else
				warn("Ошибка: Канал RBXGeneral не найден.")
			end
		else
			-- Если TextChatService не используется, пробуем старый метод чата
			local chatBar = player.PlayerGui:FindFirstChild("Chat") and player.PlayerGui.Chat:FindFirstChild("Frame") and player.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.ChatBar
			if chatBar then
				chatBar.Text = message
				local chatModule = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("ChatScript"):WaitForChild("ChatMain"))
				chatModule.MessagePosted:Fire(message)
			else
				warn("Ошибка: Не удалось найти чат-бар или модуль чата.")
			end
		end
	end)
	if not success then
		warn("Ошибка при отправке сообщения: " .. tostring(result))
	end
end

-- Функция для отправки случайного сообщения
local function sendRandomMessage()
	if isChasing then
		local randomIndex = math.random(1, #messages)
		sendChatMessage(messages[randomIndex])
	end
end

-- Функция для преследования с учётом смещения
local function chaseTarget()
	if isChasing and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local targetRoot = targetPlayer.Character.HumanoidRootPart
		local targetPosition = targetRoot.Position + offset -- Применяем смещение
		humanoid:MoveTo(targetPosition)
	end
end

-- Таймер для сообщений
local messageTimer = 0
local messageInterval = 30 -- Интервал в секундах

-- Обработка нажатия кнопки
button.Activated:Connect(function()
	local inputNick = textBox.Text
	targetPlayer = Players:FindFirstChild(inputNick)
	
	if targetPlayer and targetPlayer ~= player then
		isChasing = true
		textBox.Text = "Бежим за " .. inputNick
		messageTimer = 0 -- Сбрасываем таймер
	else
		isChasing = false
		textBox.Text = "Игрок не найден!"
	end
end)

-- Остановка преследования при нажатии клавиши (Esc)
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape then
		isChasing = false
		targetPlayer = nil
		textBox.Text = "Преследование остановлено"
	end
end)

-- Обновление преследования и таймера сообщений
RunService.Heartbeat:Connect(function(deltaTime)
	if isChasing then
		chaseTarget()
		-- Обновляем таймер
		messageTimer = messageTimer + deltaTime
		if messageTimer >= messageInterval then
			sendRandomMessage()
			messageTimer = 0 -- Сбрасываем таймер
		end
	end
end)

-- Обновление персонажа при респавне
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
end)

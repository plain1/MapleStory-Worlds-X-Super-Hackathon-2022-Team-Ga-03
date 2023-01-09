beforeFind3{
    Property: 
        --@[None]
        string tableName = "beforeFind3"
		--@[None]
		number count = 0
		--@[None]
		any npcTalkData = nil
		--@[None]
		Entity uiNameEntity = nil
		--@[None]
		Entity uiMessageEntity = nil
		--@[None]
		Entity uiTalkPanel = /ui/NPCTalk/TalkPanel
		--@[None]
		Entity uiPortraitEntity = nil
		--@[Sync]
		string player1 = ""
		--@[None]
		boolean checkingOne = false
    Function:
        void ShowNextText()
		{
			--해당 npctalk컴포넌트를 duplicate하고, 
			-- tablename에 각각 대화창을 구성하는 dataset이름을 추가하면됨. 
			if _DataService:GetTable(self.tableName) == nil then
				log("올바른 테이블명이 아닙니다. 다시 확인해주세요. 입력된 테이블 명 : "..self.tableName)
				return
			end

			--플레이어 이름출력하려면 string player1 + talkpanel경로 추가 해야함
			--그냥 npc이름만 출력하려면 string player1지우고, talkPanel경로도 제거, 아래코드도 수정
			local isNameEnable = false
			local isPortraitEnable = false

			-- GetRowCount() 함수는 테이블의 Row(행) 갯수를 가져옴
			local rowCount = self.npcTalkData:GetRowCount()

			if rowCount < self.count then
				-- rowCount 보다 self.count가 큰 경우 -> 대화가 끝남
				-- 대화가 끝나면 대화창을 닫아주고 self.count를 1로 리셋시켜줌
				-- self.count 1로 초기화 안해주면 대화 프로세스 한번 끝나면 다시 대화창 안열림
				self.uiTalkPanel.Enable = false
				self.count = 1
				return
			end
			--
			local message = self.npcTalkData:GetCell(self.count, "text")
			--log("엔피씨 대사 : "..message)

			if message == nil then
				self.uiTalkPanel.Enable = false
				self.count =1
				return
			else
				self.uiTalkPanel.Enable = true
				self.uiMessageEntity.TextComponent.Text = message
			end

			local name = self.npcTalkData:GetCell(self.count, "name")
			local portrait = self.npcTalkData:GetCell(self.count, "portrait")

			--if name ~= "" then
			--isNameEnable = true
			--    self.uiNameEntity.TextComponent.Text = name
			--name

			if name ~= "" then
				isNameEnable = true
				if name == "player1" then
					self.player1 = _UserService.LocalPlayer.NameTagComponent.Name
					name = self.player1
				end
				self.uiNameEntity.TextComponent.Text = name
			end
			--위에거로 하면 그냥 npc출력, 아래거로하면 player이름 출력

			if portrait ~= "" then
				isPortraitEnable = true
				self.uiPortraitEntity.SpriteGUIRendererComponent.ImageRUID = portrait
			end

			self.uiNameEntity.Enable = isNameEnable
			self.uiPortraitEntity.Enable = isPortraitEnable

			self.count = self.count + 1
		}

		--@client only
		void OnBeginPlay()
		{
			self.count = 1 --대화창을 시작하기위한 변수
			self.checkingOne = true --트리거대화창을 한번만 보여주기위한 변수
			self.npcTalkData = _DataService:GetTable(self.tableName)
			self.uiNameEntity = _EntityService:GetEntityByPath("/ui/NPCTalk/TalkPanel/Name")
			self.uiMessageEntity = _EntityService:GetEntityByPath("/ui/NPCTalk/TalkPanel/Text")
			self.uiTalkPanel = _EntityService:GetEntityByPath("/ui/NPCTalk/TalkPanel")
			self.uiPortraitEntity = _EntityService:GetEntityByPath("/ui/NPCTalk/TalkPanel/Portrait")
		}
		
		--@client only
		void OnMapLeave(any leftMap)
		{
			self.uiTalkPanel.Enable = false
		}


    Entity Event Handler:
		--@service InputService
		HandleKeyDownEvent(KeyDownEvent event)
		{
			-- Parameters
			local key = event.key
			--------------------------------------------------------
			if (key == KeyboardKey.Z) then
				if (self.count >= 2) then
					self:ShowNextText()
				end
			end
		}
		--@client only self
		HandleTriggerEnterEvent (TriggerEnterEvent event)
		{
			-- Parameters
			local TriggerBodyEntity = event.TriggerBodyEntity
			--------------------------------------------------------
			if TriggerBodyEntity == _UserService.LocalPlayer and self.checkingOne == true then
				if (self.count == 1) then 
					self:ShowNextText()
					self.checkingOne = false --한번출력후 false로 바꾸어 두번출력을 방지
				end
			end
		}
		--@service Inputservice
		HandleScreenTouchEvent(ScreenTouchEvent event)
		{
			-- Parameters
			local TouchPoint = event.TouchPoint
			--------------------------------------------------------
			if self.count >= 2 then
				self:ShowNextText()
			end
		}
}

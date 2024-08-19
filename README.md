# Grammar_Spelling_Check

# Description of the application
/ Описание работы приложения /

# Checking grammar and spelling with identifying errors and options for replacing incorrect words
/ Проверка грамматики и орфографии с выявлением ошибок и вариантов замены неправильных слов. /

# 1. Add text for checking in text field, tab button "Check". Grammar mistakes will be highlighted with pink colour, spelling - blue.
/ Добавьте текст для проверки в текстовое поле, кнопка вкладки «Проверить». Грамматические ошибки будут выделены розовым цветом, орфографические – синим. /

https://github.com/user-attachments/assets/39e4c1df-1bfb-4b15-be09-92f4393c5ff9

# 2. In order to view errors, you need to click on the highlighted word. A pop-up menu will offer replacement options. To replace an error with the most suitable option, select it from the pop-up menu. The word or phrase in the text will be replaced with the correct one
/ Для того, чтобы просмотреть ошибки, необходимо нажать на выделенное слово. Всплывающее меню предложит варианты замены. Чтобы заменить ошибку на наиболее подходящий вариант, выберите его из всплывающего меню. Слово или фраза в тексте будет заменена на правильную /

https://github.com/user-attachments/assets/9be29d24-1203-4d13-aaee-1d876fadea50

# 3. You can make edits to the text without losing highlighted errors
/ Вы можете вносить правки в текст, не теряя выделенных ошибок. /

https://github.com/user-attachments/assets/09d1c261-e471-40d7-b544-b83c5545ec63

https://github.com/user-attachments/assets/44093f98-3e9d-45fc-87b1-126c255111b7

# 4. After checking and editing the text, you can reset it with the button "Reset"
/ После проверки и редактирования текста его можно сбросить кнопкой «Сбросить». /

https://github.com/user-attachments/assets/0508823c-9a3a-4edf-b8d2-8d670da188b0

# Challenges and Solutions:
/ Проблемы и решения /

# 1. I encountered a problem with placing text, highlighting errors, and showing replacement options when clicking on an error.
/ Столкнулась с проблемой размещения текста, подсветки ошибок и показа вариантов замены при нажатии на ошибку. /

   # Solution:
   / Решение /
   
     Similar to Deeplink mechanism, which has expansion capabilities. 
     / Подобие Deeplink механизма, который имеет возможности расширения. /
   
  #  - Marking: 
  / Разметка /
  
     `errors
    .forEach { error in
        let color: UIColor
        if error.type == "grammar" {
            color = UIColor(red: 1, green: 0.38, blue: 0.53, alpha: 0.1)
        } else if error.type == "spelling" {
            color = UIColor(red: 0.24, green: 0.29, blue: 0.85, alpha: 0.1)
        } else {
            return
        }
        let range = NSRange(location: error.offset, length: error.length)
        attributedString.addAttribute(.backgroundColor, value: color, range: range)
        attributedString.addAttribute(
            .link,
            value: ErrorURLBuilder(errorId: error.id).url,
            range: range
        )
    }`

   # - Deeplink generator:
   / Deeplink генератор /
  
     <img width="736" alt="Снимок экрана 2024-08-01 в 14 42 32" src="https://github.com/user-attachments/assets/a0a5968e-5289-4f01-affe-91281abe7d6e">

# ! It was important to leave the ability to edit the text after highlighting errors:
/ Важно было оставить возможность редактирования текста после выделения ошибок /

# 2. It was necessary to exclude duplicates from UITextView, queue updates and apply only correct updates.
/ Необходимо было исключить дубликаты от UITextView, выстроить очередь обновлений и применять только корректные обновления. /

   # Solution:
   / Решение /
   
  # - A structure that describes an update from the user: 
  / Структура которая описывает обновление от пользователя /
  
<img width="523" alt="Снимок экрана 2024-08-01 в 14 54 29" src="https://github.com/user-attachments/assets/c0ea7ad2-5e47-4f54-ac2f-2d18afc70bf3">

  # - Applying updates: 
  / Применение обновлений /
  
<img width="523" alt="Снимок экрана 2024-08-01 в 14 57 12" src="https://github.com/user-attachments/assets/4de8a242-ef17-446c-ba65-1119c0effede">

# 3. After editing the text by the user, it is necessary to recalculate all locations of errors in the text.
/ После редактирования текста пользователем необходимо пересчитать все расположения ошибок в тексте. /

   # Solution: 
   / Решение /
   
 # Depending on the location of the change and the size of the text, different recalculation logic is used
 / В зависимости от места изменения и размера текста используется разная логика пересчета /
 
<img width="533" alt="Снимок экрана 2024-08-01 в 15 04 55" src="https://github.com/user-attachments/assets/9157f378-c1e3-47bd-8917-e53bdca28e9b">

 <img width="521" alt="Снимок экрана 2024-08-01 в 15 05 59" src="https://github.com/user-attachments/assets/3cb8a784-120a-46ee-9e43-fe1565077579">


<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BlikLite Hand v7.0 | Носимый интерфейс управления</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600&family=Manrope:wght@400;700;800&display=swap" rel="stylesheet">
    <style>
        :root { 
            --bg-dark: #09090b; 
            --bg-card: rgba(255, 255, 255, 0.03); 
            --border: rgba(255, 255, 255, 0.08); 
            --text-main: #a1a1aa; 
            --text-light: #f4f4f5; 
            --accent-blue: #3b82f6; 
            --accent-green: #10b981; 
        }
        * { box-sizing: border-box; margin: 0; padding: 0; scroll-behavior: smooth; }
        body { 
            font-family: 'Inter', sans-serif; 
            background-color: var(--bg-dark); 
            color: var(--text-main); 
            line-height: 1.7; 
            overflow-x: hidden; 
            background-image: radial-gradient(circle at 15% 0%, rgba(59, 130, 246, 0.15) 0%, transparent 40%), radial-gradient(circle at 85% 100%, rgba(16, 185, 129, 0.1) 0%, transparent 40%); 
            background-attachment: fixed; 
        }

        /* Эффект сканирующей линии (HUD) */
        .scanline {
            position: fixed;
            top: 0; left: 0; width: 100vw; height: 2px;
            background: linear-gradient(to right, transparent, var(--accent-blue), transparent);
            opacity: 0.3;
            animation: scan 6s linear infinite;
            z-index: 9999;
            pointer-events: none;
        }
        @keyframes scan { 0% { top: 0; } 100% { top: 100vh; } }

        .container { max-width: 1100px; margin: 0 auto; padding: 100px 20px; position: relative; z-index: 1; }
        
        header { text-align: center; margin-bottom: 80px; animation: fadeIn 1.2s ease-out; }
        h1 { 
            font-family: 'Manrope', sans-serif; 
            font-size: clamp(2.5rem, 6vw, 4.5rem); 
            font-weight: 800; 
            color: var(--text-light); 
            letter-spacing: -2px; 
            margin-bottom: 15px; 
            background: linear-gradient(180deg, #fff 0%, #a1a1aa 100%); 
            -webkit-background-clip: text; 
            -webkit-text-fill-color: transparent; 
            text-shadow: 0 0 40px rgba(59, 130, 246, 0.3);
        }
        .subtitle { font-size: 1.2rem; color: var(--accent-blue); font-weight: 600; letter-spacing: 1px; margin-bottom: 30px; text-transform: uppercase;}
        .author { display: inline-flex; align-items: center; gap: 10px; padding: 8px 20px; background: rgba(255, 255, 255, 0.05); border: 1px solid var(--border); border-radius: 50px; font-size: 0.95rem; color: var(--text-light); backdrop-filter: blur(10px); }
        .author::before { content: ''; display: block; width: 8px; height: 8px; background: var(--accent-green); border-radius: 50%; box-shadow: 0 0 10px var(--accent-green); }
        
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 24px; }
        
        .card { 
            background: var(--bg-card); 
            border: 1px solid var(--border); 
            border-radius: 24px; 
            padding: 30px; 
            position: relative; 
            backdrop-filter: blur(20px); 
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1); 
            opacity: 0; 
            transform: translateY(20px); 
            animation: slideUp 0.8s ease-out forwards; 
            overflow: hidden;
        }
        .card::before {
            content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: radial-gradient(circle at 50% 0%, rgba(59, 130, 246, 0.1), transparent 70%);
            opacity: 0; transition: opacity 0.4s; pointer-events: none;
        }
        .card:hover::before { opacity: 1; }
        .card:nth-child(1) { animation-delay: 0.1s; } .card:nth-child(2) { animation-delay: 0.2s; } .card:nth-child(3) { animation-delay: 0.3s; } .card:nth-child(4) { animation-delay: 0.4s; }
        .card:hover { transform: translateY(-5px) scale(1.01); border-color: rgba(59, 130, 246, 0.4); box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4); }
        
        .card h2 { font-family: 'Manrope', sans-serif; font-size: 1.4rem; font-weight: 700; color: var(--text-light); margin-bottom: 20px; display: flex; align-items: center; gap: 12px; }
        .card h2::before { content: ''; display: block; width: 4px; height: 24px; background: var(--accent-blue); border-radius: 4px; box-shadow: 0 0 10px var(--accent-blue);}
        .card h3 { font-family: 'Manrope', sans-serif; font-size: 1.1rem; font-weight: 600; color: var(--text-light); margin: 20px 0 10px 0; }
        p { font-size: 1rem; font-weight: 300; margin-bottom: 15px; }
        ul { list-style: none; padding-left: 0; }
        li { position: relative; padding-left: 25px; margin-bottom: 12px; font-size: 0.95rem; }
        li::before { content: '▹'; position: absolute; left: 0; color: var(--accent-blue); font-size: 1.2rem; line-height: 1.2; top: 1px; }
        strong { color: var(--text-light); font-weight: 600; }
        
        /* Вопросы */
        .question-box { background: rgba(255, 255, 255, 0.02); border: 1px solid var(--border); border-radius: 16px; padding: 20px; margin-bottom: 20px; transition: 0.3s; }
        .question-box:hover { border-color: rgba(245, 158, 11, 0.4); background: rgba(245, 158, 11, 0.02); }
        .question-box h3 { color: #f59e0b; margin-top: 0; margin-bottom: 10px; }
        .note { background: rgba(59, 130, 246, 0.1); border-left: 3px solid var(--accent-blue); padding: 12px 15px; margin-top: 10px; border-radius: 0 8px 8px 0; font-size: 0.9rem; color: #93c5fd; }
        
        /* Кнопки */
        .btn-messenger { display: inline-flex; align-items: center; gap: 10px; padding: 15px 35px; background: linear-gradient(90deg, var(--accent-blue), #8b5cf6); color: #fff; font-family: 'Manrope', sans-serif; font-size: 1.1rem; font-weight: 700; text-decoration: none; border-radius: 50px; transition: 0.3s; box-shadow: 0 10px 20px rgba(59, 130, 246, 0.3); border: none; cursor: pointer;}
        .btn-messenger:hover { transform: translateY(-3px); box-shadow: 0 15px 30px rgba(59, 130, 246, 0.5); }
        
        /* Форма */
        .feedback-section { grid-column: 1 / -1; background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(16, 185, 129, 0.05)); border: 1px solid rgba(59, 130, 246, 0.3); border-radius: 24px; padding: 40px; text-align: center; margin-top: 40px; }
        .feedback-section h2 { justify-content: center; color: var(--text-light); margin-bottom: 10px; font-size: 1.8rem; }
        .feedback-section h2::before { display: none; }
        .feedback-section p { color: var(--text-main); margin-bottom: 30px; }
        .rating-stars { display: flex; justify-content: center; gap: 10px; margin-bottom: 30px; flex-direction: row-reverse; }
        .rating-stars input { display: none; }
        .rating-stars label { font-size: 2.5rem; color: rgba(255,255,255,0.1); cursor: pointer; transition: 0.2s; }
        .rating-stars label:hover, .rating-stars label:hover ~ label, .rating-stars input:checked ~ label { color: #ffeb3b; text-shadow: 0 0 15px #ffeb3b; }
        form { max-width: 600px; margin: 0 auto; display: flex; flex-direction: column; gap: 15px; }
        input[type="text"], textarea { width: 100%; padding: 15px 20px; background: rgba(0, 0, 0, 0.3); border: 1px solid var(--border); border-radius: 12px; color: var(--text-light); font-family: 'Inter', sans-serif; font-size: 1rem; outline: none; transition: 0.3s; }
        input[type="text"]:focus, textarea:focus { border-color: var(--accent-blue); box-shadow: 0 0 15px rgba(59, 130, 246, 0.2); }
        textarea { resize: vertical; min-height: 120px; }
        button[type="submit"] { padding: 15px 30px; background: linear-gradient(90deg, var(--accent-blue), #8b5cf6); border: none; border-radius: 12px; color: #fff; font-weight: 700; font-size: 1.1rem; cursor: pointer; transition: 0.3s; font-family: 'Manrope', sans-serif; letter-spacing: 1px; }
        button[type="submit"]:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(59, 130, 246, 0.3); }
        .footer { text-align: center; padding: 40px; border-top: 1px solid var(--border); color: #52525b; font-size: 0.9rem; margin-top: 40px; }
        
        /* Блок сборки */
        .assembly-section { grid-column: 1 / -1; background: linear-gradient(135deg, rgba(16, 185, 129, 0.05), rgba(59, 130, 246, 0.05)); border: 1px solid rgba(16, 185, 129, 0.3); border-radius: 24px; padding: 40px; margin-bottom: 24px; }
        .assembly-section h2 { color: var(--accent-green); margin-bottom: 20px; border-bottom: 1px solid rgba(16, 185, 129, 0.2); padding-bottom: 15px; font-size: 1.8rem; display: flex; align-items: center; gap: 15px; }
        .assembly-section h2::before { content: '🛠️'; font-size: 1.8rem; }
        .assembly-text { font-size: 1.05rem; color: var(--text-main); margin-bottom: 25px; }
        .hand-box { background: rgba(255, 255, 255, 0.02); border: 1px solid var(--border); border-radius: 16px; padding: 25px; margin-bottom: 20px; transition: 0.3s; }
        .hand-box:hover { border-color: rgba(16, 185, 129, 0.3); }
        .hand-box h3 { color: var(--text-light); font-size: 1.3rem; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }
        .left-hand h3::before { content: '⏱️'; }
        .right-hand h3::before { content: '🖐️'; }
        .hand-box ul { margin-top: 10px; }
        .hand-box li { font-size: 1rem; color: #d4d4d8; }
        .hand-box li::before { content: '▹'; color: var(--accent-green); }

        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        @media (max-width: 768px) { .container { padding: 50px 15px; } .card { padding: 20px; } h1 { letter-spacing: -1px; font-size: 2rem; } .grid { grid-template-columns: 1fr; } .assembly-section { padding: 20px; } }
    </style>
</head>
<body>
    <div class="scanline"></div> <!-- Сканирующая линия -->
    
    <div class="container">
        <header>
            <h1>BlikLite Hand v7.0</h1>
            <div class="subtitle">Компактный носимый интерфейс управления</div>
            <div class="author">Создатель: Петров Андрей</div>
        </header>
        
        <div class="grid">
            <div class="card" style="grid-column: 1 / -1;">
                <h2>1. Концепция проекта</h2>
                <p>BlikLite Hand — это носимый интерфейс, объединяющий реальный мир с цифровым. Устройство позволяет управлять роботами, умными устройствами и компьютером с помощью движений руки и компактного пульта управления в виде умных часов на запястье.</p>
                <h3>Главная идея</h3>
                <p>Технологии становятся все меньше, но интерфейсы остаются громоздкими. Моя цель — создать универсальный портативный продукт, который сделает управление сложной техникой интуитивно понятным. Мы уходим от громоздких макеток к реальному носимому гаджету.</p>
            </div>
            
            <div class="card">
                <h2>Левая рука (Умные часы)</h2>
                <ul>
                    <li><strong>Контроллер:</strong> ESP32-C6-Touch-LCD-1.47 (Pre-soldered) — интеграционное решение "все в одном".</li>
                    <li><strong>Экран и Тач:</strong> 1.47" IPS 172x320 со встроенным емкостным тачскрином (листание меню пальцем).</li>
                    <li><strong>Гироскоп:</strong> Встроенный чип QMI8658 (не требует отдельного MPU-6050).</li>
                    <li><strong>Связь:</strong> Встроенная керамическая антенна Wi-Fi 6 и Bluetooth 5.</li>
                </ul>
            </div>
            
            <div class="card">
                <h2>Правая рука (Сенсорный модуль)</h2>
                <ul>
                    <li><strong>Контроллер:</strong> ESP32-S3-Zero — крошечная плата для максимальной компактности.</li>
                    <li><strong>Дальномер:</strong> VL53L0X (GY-530) — лазерный, точность до 2 метров. Заменил громоздкий ультразвук.</li>
                    <li><strong>Гироскоп (MPU-6050):</strong> Отслеживает наклон кисти для управления поворотом камер или дронов.</li>
                    <li><strong>Лазерный модуль:</strong> Визуальное целеуказание.</li>
                </ul>
            </div>
            
            <div class="card">
                <h2>Связь и Питание</h2>
                <h3>Связь</h3>
                <p>Протокол ESP-NOW: прямая радиосвязь между часами (C6) и модулем (S3-Zero). Дальность стабильного сигнала: до 500 метров на открытой местности.</p>
                <h3>Питание</h3>
                <p>Автономная работа от миниатюрных Li-Po аккумуляторов (3.7V) с модулями зарядки TP4056 Type-C. Обе части полностью беспроводные.</p>
            </div>

            <!-- БЛОК КОНСТРУКЦИИ -->
            <div class="assembly-section">
                <h2>Конструкция и эргономика</h2>
                <p class="assembly-text">Проект переходит на новый уровень: от макетных плат к интегральным решениям. Обе части устройства будут спрятаны в защитные чехлы для максимального удобства.</p>
                
                <div class="hand-box left-hand">
                    <h3>Левая рука: Часы</h3>
                    <p>Плата ESP32-C6-Touch-LCD-1.47 вместе с аккумулятором крепится на запястье как обычные часы.</p>
                    <ul>
                        <li><strong>Интерфейс:</strong> Управление меню и функциями происходит напрямую через тачскрин.</li>
                        <li><strong>Дисплей:</strong> Отображает список найденных IP-устройств, их расстояние и статус подключения.</li>
                    </ul>
                </div>

                <div class="hand-box right-hand">
                    <h3>Правая рука: Сенсорный модуль</h3>
                    <p>На тыльной стороне ладони или как компактный браслет на запястье размещается мини-корпус со всеми датчиками.</p>
                    <ul>
                        <li><strong>ESP32-S3-Zero:</strong> Обеспечивает беспроводную связь с часами и обработку данных с датчиков.</li>
                        <li><strong>VL53L0X:</strong> Лазерный дальномер (I2C). Измеряет расстояние до объектов для навигации.</li>
                        <li><strong>MPU-6050:</strong> Отслеживает поворот руки (жесты).</li>
                        <li><strong>Лазер KY-008:</strong> Включается по взмаху руки.</li>
                    </ul>
                    <p style="margin-top: 15px; font-style: italic; color: #888;">Все датчики висят на одной шине I2C (SDA/SCL), что позволяет сэкономить пины на ESP32-S3-Zero. Корпус планируется напечатать на 3D-принтере.</p>
                </div>
            </div>

            <!-- БЛОК ВОПРОСОВ -->
            <div class="card" style="grid-column: 1 / -1;">
                <h2>Вопросы для инженерной консультации</h2>
                <div class="question-box">
                    <h3>Вопрос 1. Шина I2C и адресация</h3>
                    <p>У меня на правой руке (ESP32-S3-Zero) висят два I2C-устройства: VL53L0X (дальномер) и MPU-6050 (гироскоп). Могу ли я подключить их параллельно на одни и те же пины SDA/SCL? Не будет ли конфликта адресов, и нужны ли подтягивающие резисторы, если на модулях они уже распаяны?</p>
                </div>
                <div class="question-box">
                    <h3>Вопрос 2. Питание ESP32-S3-Zero</h3>
                    <p>У платы ESP32-S3-Zero нет USB-UART чипа. Для прошивки нужно включать режим USB CDC On Boot в Arduino IDE. Вопрос: насколько стабильно она работает от Li-Po аккумулятора 3.7V? Нужен ли внешний DC-DC преобразователь для стабильного питания датчиков или встроенного стабилизатора хватит?</p>
                </div>
                <div class="question-box">
                    <h3>Вопрос 3. Тачскрин и гироскоп на ESP32-C6</h3>
                    <p>На плате ESP32-C6-Touch-LCD-1.47 тачскрин и встроенный гироскоп (QMI8658) сидят на одной шине I2C. Как правильно организовать опрос тача и гироскопа, чтобы они не мешали друг другу? Нужно ли использовать разные библиотеки или можно обойтись стандартными средствами?</p>
                    <div class="note"><strong>Примечание:</strong> Это касается программирования и распределения ресурсов на шине.</div>
                </div>
                <div class="question-box">
                    <h3>Вопрос 4. Жесты на MPU-6050</h3>
                    <p>Я планирую реализовать распознавание жестов (например, взмах рукой) прямо на ESP32-S3-Zero. Хватит ли мощности процессора для обработки данных с гироскопа и запуска простой нейросети на TensorFlow Lite, или лучше использовать простую пороговую фильтрацию (если угловая скорость > 300 град/с — это взмах)?</p>
                </div>
            </div>

            <div style="grid-column: 1 / -1; text-align: center; margin: 20px 0;">
                <a href="https://bliklitechat.relaxdev.ru" target="_blank" class="btn-messenger">🚀 Попробовать BlikLite Messenger</a>
                <p style="color: #9ca3af; margin-top: 15px; font-size: 0.9rem;">Нажми, чтобы перейти в живой мессенджер</p>
            </div>
            
            <div class="feedback-section">
                <h2>Оцените проект</h2>
                <p>Ваше мнение очень важно для развития BlikLite Hand!<br>Поставьте оценку и сообщите о своих идеях и доработках.</p>
                <form name="feedback" method="POST" data-netlify="true" netlify-honeypot="bot-field" onsubmit="event.preventDefault(); submitFeedback(this);">
                    <input type="hidden" name="form-name" value="feedback" />
                    <p style="display:none;"><label>Don’t fill this out: <input name="bot-field" /></label></p>
                    <div class="rating-stars">
                        <input type="radio" id="star5" name="rating" value="5" /><label for="star5">★</label>
                        <input type="radio" id="star4" name="rating" value="4" /><label for="star4">★</label>
                        <input type="radio" id="star3" name="rating" value="3" /><label for="star3">★</label>
                        <input type="radio" id="star2" name="rating" value="2" /><label for="star2">★</label>
                        <input type="radio" id="star1" name="rating" value="1" /><label for="star1">★</label>
                    </div>
                    <input type="text" name="name" placeholder="Ваше имя (необязательно)" />
                    <textarea name="comment" placeholder="Ваш комментарий или вопрос..." required></textarea>
                    <button type="submit">Отправить отзыв</button>
                </form>
                <div id="formSuccessMessage" style="display:none; color: #22c55e; text-align: center; margin-top: 20px; font-weight: bold; font-size: 1.2rem; padding: 20px; background: rgba(34, 197, 94, 0.1); border: 1px solid #22c55e; border-radius: 12px;">✅ Спасибо! Ваш отзыв успешно отправлен.</div>
            </div>
        </div>
        <div class="footer">&copy; 2026 BlikLite Hand. Инженерный проект. Все права защищены.</div>
    </div>
    
    <script>
        function submitFeedback(form) {
            const formData = new FormData(form);
            const encoded = new URLSearchParams(formData).toString();
            fetch("/", { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body: encoded })
            .then(() => {
                form.style.display = 'none';
                document.getElementById('formSuccessMessage').style.display = 'block';
                const rating = formData.get('rating') || 'Не указана';
                const name = formData.get('name') || 'Аноним';
                const comment = formData.get('comment') || '';
                fetch('/.netlify/functions/send-telegram', {
                    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ rating, name, comment })
                }).catch(err => console.error("Ошибка функции:", err));
            })
            .catch((error) => { alert("Ошибка отправки в Netlify. Попробуйте еще раз."); });
        }
    </script>
</body>
</html>

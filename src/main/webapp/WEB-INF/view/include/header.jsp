<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>반응형 헤더</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Roboto', sans-serif;
        }

        /* Header */
        #header {
            width: 100%;
            max-width: 1920px;
            padding: 22px 20px;
            background: rgba(250, 250, 250, 0);
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 30px;
            margin: 0 auto;
        }

        /* Icon Button */
        #menu-button {
            width: 48px;
            height: 48px;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            border: none;
            background: none;
            padding: 0;
        }

        #menu-button-content {
            width: 40px;
            height: 40px;
            background: #6750A4;
            border-radius: 100px;
            display: flex;
            justify-content: center;
            align-items: center;
            transition: background 0.2s;
        }

        #menu-button:hover #menu-button-content {
            background: #5644A0;
        }

        .icon {
            width: 24px;
            height: 24px;
            color: white;
        }

        .menu-icon {
            width: 18px;
            height: 12px;
            background: white;
        }

        /* Contents */
        #contents {
            width: 100%;
            max-width: 1200px;
            padding: 32px;
            background: rgba(250, 250, 250, 0);
            border-bottom: 1px solid #D9D9D9;
            display: flex;
            justify-content: flex-start;
            align-items: center;
            gap: 24px;
            flex-wrap: wrap;
        }

        /* Navigation Pill List */
        #navigation-pill-list {
            flex: 1 1 0;
            display: flex;
            justify-content: flex-end;
            align-items: flex-start;
            gap: 8px;
            flex-wrap: wrap;
        }

        .navigation-pill {
            padding: 8px;
            border-radius: 8px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: background 0.2s;
            text-decoration: none;
        }

        .navigation-pill:hover {
            background: #F5F5F5;
        }

        .navigation-title {
            color: #1E1E1E;
            font-size: 16px;
            font-family: 'Inter', sans-serif;
            font-weight: 400;
            line-height: 16px;
        }

        /* Search Bar */
        #search-bar {
            width: 360px;
            height: 56px;
            max-width: 720px;
            background: #ECE6F0;
            border-radius: 28px;
            display: flex;
            justify-content: flex-start;
            align-items: center;
            gap: 4px;
            overflow: hidden;
        }

        #search-state-layer {
            flex: 1 1 0;
            height: 100%;
            padding: 4px;
            display: flex;
            justify-content: flex-start;
            align-items: center;
            position: relative;
        }

        .search-icon-wrapper {
            width: 48px;
            height: 48px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .search-icon-content {
            width: 40px;
            height: 40px;
            border-radius: 100px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .search-icon {
            width: 18px;
            height: 12px;
            background: #49454F;
        }

        .search-icon-magnify {
            width: 18px;
            height: 18px;
            background: #49454F;
        }

        #search-content {
            flex: 1 1 0;
            height: 100%;
            padding: 0 20px;
            display: flex;
            justify-content: flex-start;
            align-items: center;
        }

        #search-input {
            border: none;
            outline: none;
            background: transparent;
            color: #49454F;
            font-size: 16px;
            font-family: 'Roboto', sans-serif;
            font-weight: 400;
            line-height: 24px;
            letter-spacing: 0.5px;
            width: 100%;
        }

        #search-input::placeholder {
            color: #49454F;
        }

        #search-trailing-icon {
            position: absolute;
            right: 4px;
            width: 48px;
            height: 48px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* Register Button */
        #register-button {
            background: #6750A4;
            border-radius: 16px;
            border: none;
            cursor: pointer;
            transition: background 0.2s;
        }

        #register-button:hover {
            background: #5644A0;
        }

        #register-button-content {
            padding: 16px 24px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
        }

        #register-label {
            color: white;
            font-size: 16px;
            font-family: 'Roboto', sans-serif;
            font-weight: 500;
            line-height: 24px;
            letter-spacing: 0.15px;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            #header {
                flex-wrap: wrap;
            }

            #search-bar {
                width: 100%;
                max-width: 100%;
            }
        }

        @media (max-width: 768px) {
            #contents {
                padding: 16px;
            }

            #navigation-pill-list {
                flex-direction: column;
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <header id="header">
        <!-- Icon Button -->
        <button id="menu-button" type="button">
            <div id="menu-button-content">
                <svg class="icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="3" y="6" width="18" height="2" fill="currentColor"/>
                    <rect x="3" y="11" width="18" height="2" fill="currentColor"/>
                    <rect x="3" y="16" width="18" height="2" fill="currentColor"/>
                </svg>
            </div>
        </button>

        <!-- Contents -->
        <div id="contents">
            <!-- Navigation Pill List -->
            <nav id="navigation-pill-list">
                <a href="#" id="nav-pill-0" class="navigation-pill">
                    <div class="photoList.jsp">Photo</div>
                </a>
                <a href="#" id="nav-pill-1" class="navigation-pill">
                    <div class="communityList.jsp">Community</div>
                </a>
                <a href="#" id="nav-pill-2" class="navigation-pill">
                    <div class="mapList.jsp">Map</div>
                </a>
                <a href="#" id="readingMarket" class="navigation-pill">
                    <div class="marketList.jsp">Market</div>
                </a>
                <a href="#" id="nav-pill-4" class="navigation-pill">
                    <div class="navigation-title">Contact|작동안함</div>
                </a>
                <a href="#" id="nav-pill-5" class="navigation-pill">
                    <div class="navigation-title">Link|작동안함</div>
                </a>
            </nav>
        </div>

        <!-- Search Bar -->
        <div id="search-bar">
            <div id="search-state-layer">
                <!-- Leading Icon -->
                <div id="search-leading-icon" class="search-icon-wrapper">
                    <div class="search-icon-content">
                        <svg class="icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <rect x="3" y="6" width="18" height="2" fill="#49454F"/>
                            <rect x="3" y="11" width="18" height="2" fill="#49454F"/>
                            <rect x="3" y="16" width="18" height="2" fill="#49454F"/>
                        </svg>
                    </div>
                </div>

                <!-- Search Content -->
                <div id="search-content">
                    <input 
                        id="search-input" 
                        type="text" 
                        placeholder="Hinted search text"
                    />
                </div>

                <!-- Trailing Icon -->
                <div id="search-trailing-icon" class="search-icon-wrapper">
                    <div class="search-icon-content">
                        <svg class="icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="11" cy="11" r="6" stroke="#49454F" stroke-width="2" fill="none"/>
                            <line x1="15.5" y1="15.5" x2="20" y2="20" stroke="#49454F" stroke-width="2" stroke-linecap="round"/>
                        </svg>
                    </div>
                </div>
            </div>
        </div>

        <!-- Register Button -->
        <button id="register-button" type="button">
            <div id="register-button-content">
                <span id="register-label">프로필</span>
            </div>
        </button>
    </header>

    <script>
        // Menu button toggle functionality
        document.getElementById('menu-button').addEventListener('click', function() {
            var navList = document.getElementById('navigation-pill-list');
            if (navList.style.display === 'none') {
                navList.style.display = 'flex';
            } else {
                navList.style.display = 'none';
            }
        });
    </script>
</body>
</html>
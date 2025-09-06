-- Waiting time for antispam
ANTI_SPAM_TIMER = 2

-- Verification and allocation of a free place
CHECK_PLACES_TIMER = 3

-- Update of the message (emojis) and access to the free place for the lucky one
REFRESH_EMOJIS_TIMER = 3

-- Number of points updating
UPDATE_POINTS_TIMER = 6

-- Number of points earned for those who are waiting
ADD_POINTS_WHILE_WAITING = 1

-- Number of points lost for those who entered the server
REMOVE_POINTS_ON_JOIN = 1

-- Nombre de points gagnés pour ceux qui ont 3 emojis identiques (loterie) / Number of points earned for those who have 3 identical emojis (lottery)
LOTTERY_BONUS_POINTS = 25

-- Priority access
/*QUEUE_POINTS = {
	 { "rockhvězdová licence lol", 150000 },
}*/
QUEUE_POINTS = {}

-- Si steam n'est pas détecté / If license can't be found
NO_LICENSE_MESSAGE = "Rockstar license identifikátor nebyl zaznamenán, prosím restartujte FiveM."

-- Waiting text
WAITING_MESSAGE = "Probouzíte se. | Queue pointy: %s \nAktuální pozice: %s/%s\n [ %s ]"

-- Text before emojis
EMOJI_MESSAGE = "Pokud se emoji zastaví restartujte FiveM: %s"

-- When the player win the lottery
EMOJI_BOOST_MESSAGE = "!!! GRATULUJEME, VYHRÁL/A JSTE " .. LOTTERY_BONUS_POINTS .. " queue pointů!"

-- Anti-spam message
PLEASE_WAIT_MESSAGE = "Prosím počkejte %s sekund. Připojení nastane zachvíli"

-- Should never be displayed
ACCIDENT_MESSAGE = "Při probouzení se stala příhoda... Pokud se stane znova, kontaktujte vedení."

EMOJI_LIST = {
	'🐌',  '🐍', '🐎',  '🐑', '🐒', 
    '🐘', '🐙', '🐛', '🐜', '🐝',
	'🐞', '🐟', '🐠', '🐡', '🐢',
	'🐤', '🐦', '🐧', '🐩', '🐫',
	'🐬', '🐲', '🐳', '🐴', '🐅',
	'🐈', '🐉', '🐋', '🐀', '🐇',
	'🐏', '🐐', '🐓', '🐕', '🐖',
	'🐪', '🐆', '🐄', '🐃', '🐂',
	'🐁', '🔥'
}

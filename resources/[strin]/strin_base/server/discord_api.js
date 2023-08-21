const GUILD_ID = "1021800922856304731";
const BOT_TOKEN = "MTEzNTU2Mjg5NzkwNTQyNjQ1Mg.GHq3Bc.Yiyg0lU3iUaHz61VDlcQkqThMfQT61d5wr562Y";

const ACCESS_ROLES = {
    Animal: "1142599307703357450",
    Ped: "1142599243626971318",
    Whitelist: "1125554281290928128",
}

const ERROR_MESSAGES = {
    DiscordId: "Nepovedlo se u Vás najít Discord ID. Prosím ověřte, že máte nainstalovaný a zapnutý discord",
    Whitelist: "Nemáte povolení k připojení!",
    Guild: "Nejste připojen/a na náš discord!",
    Blacklist: "Máte zablokovaný přístup na náš discord.",
}

const IS_WHITELIST_ON = false

const axios = require('axios').default;
axios.defaults.baseURL = 'https://discord.com/api/';
axios.defaults.headers = {
    'Content-Type': 'application/json',
    Authorization: `Bot ${BOT_TOKEN}`
};

GetPlayerDiscordId = (playerId) => {
    const discordId = GetPlayerIdentifierByType(playerId, "discord")
    if(!discordId || discordId == -1 || discordId == 0)
        return null;

    return discordId.replace("discord:", "");
};

DoesPlayerHaveDiscordRole = async (playerId, roleId, cb) => {
    const discordId = GetPlayerDiscordId(playerId)
    const selectedRoleId = typeof(roleId) == "string" ? (ACCESS_ROLES[roleId] || roleId) : roleId
    const result = await axios(`/guilds/${GUILD_ID}/members/${discordId}`);
    if(!result?.data) 
        return cb(false);
    if(!result?.data.roles.includes(selectedRoleId)) 
        return cb(false);

    return cb(true);
};

exports("_internalDoesPlayerHaveDiscordRole", DoesPlayerHaveDiscordRole)

exports("GetPlayerDiscordId", (playerId) => GetPlayerDiscordId(playerId))

on('playerConnecting', async (name, _, deferrals) => {
    const _source = global.source;
    deferrals.defer();
    const discordId = GetPlayerDiscordId(_source);
    if(!discordId) 
        return deferrals.done(ERROR_MESSAGES.DiscordId);

    deferrals.update(`${name} - Ověřujeme Váš discord...`)
    const result = await axios(`/guilds/${GUILD_ID}/members/${discordId}`).catch((o) => false);
    if(!result || !result?.data) 
        return deferrals.done(ERROR_MESSAGES.Guild);

    if(!IS_WHITELIST_ON) 
        return deferrals.done();

    const isWhitelisted = result.data.roles.contains(ACCESS_ROLES.Whitelist);
    if(!isWhitelisted) 
        return deferrals.done(ERROR_MESSAGES.Whitelist);

    deferrals.done();
})
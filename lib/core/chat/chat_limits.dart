/// Plaintext cap for a dead/finish chat message (#80). Comfortably under
/// the server's 2048-char ceiling on the encrypted ciphertext
/// (`send_chat`, 22-chat.sql) even accounting for AES-GCM + base64
/// overhead worst-case (4-byte-per-char UTF-8).
const maxChatMessageLength = 300;

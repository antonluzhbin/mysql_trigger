DROP TRIGGER IF EXISTS `delete_chat`;
DELIMITER //
CREATE TRIGGER `delete_chat` BEFORE DELETE ON `engine4_users_chat`
 FOR EACH ROW BEGIN

DECLARE conversation_id_secret INT;

SELECT a.conversation_id into conversation_id_secret
FROM engine4_messages_recipients AS a
JOIN engine4_messages_recipients AS b 
ON a.conversation_id = b.conversation_id
WHERE a.user_id = old.user_id_1 AND b.user_id = old.user_id_2;

insert into engine4_messages_secret (select * from engine4__messages where conversation_id = conversation_id_secret and date >= old.date);

insert into engine4_chat_whispers_secret (select * from engine4_chat_whispers where ((recipient_id = old.user_id_1 and sender_id = old.user_id_2) or (recipient_id = old.user_id_2 and sender_id = old.user_id_1)) and date >= old.date);

delete from engine4_messages where conversation_id = conversation_id_secret and date >= old.date;
delete from engine4_chat_whispers where ((recipient_id = old.user_id_1 and sender_id = old.user_id_2) or (recipient_id = old.user_id_2 and sender_id = old.user_id_1)) and date >= old.date;
END
//
DELIMITER ;

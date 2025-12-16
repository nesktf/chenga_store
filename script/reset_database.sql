BEGIN;

TRUNCATE "lapis_migrations" RESTART IDENTITY CASCADE;
TRUNCATE "cart_items" RESTART IDENTITY CASCADE;
TRUNCATE "manga_tags" RESTART IDENTITY CASCADE;
TRUNCATE "mangas" RESTART IDENTITY CASCADE;
TRUNCATE "sale_cart" RESTART IDENTITY CASCADE;
TRUNCATE "sales" RESTART IDENTITY CASCADE;
TRUNCATE "tags" RESTART IDENTITY CASCADE;
TRUNCATE "user_carts" RESTART IDENTITY CASCADE;
TRUNCATE "user_favs" RESTART IDENTITY CASCADE;
TRUNCATE "users" RESTART IDENTITY CASCADE;

INSERT INTO mangas (id, name, author, isbn, stock, price, "image_path", discount) VALUES
  (1, 'Touhou Ibara Kasen - Wild and Horned Hermit Vol. 10', 'ZUN', NULL, 100, 1500, '/image/867cb97bd3748d2726332ec7a4d215e6.png', 0),
  (2, 'Touhou Chireikiden - Hansoku Tantei Satori Vol. 3', 'ZUN', NULL, 100, 1500, '/image/c32f6b47364c9364b52bc69f82843822.png', 0),
  (3, 'Touhou Chireikiden - Hansoku Tantei Satori Vol. 4', 'ZUN', NULL, 100, 1500, '/image/bcc916c42363dd2bd4b4b8b14dd16183.jpg', 0),
  (4, 'Touhou Chireikiden - Hansoku Tantei Satori Vol. 5', 'ZUN', NULL, 100, 1500, '/image/6556b796f6070c75cf200730a83a8b93.jpeg', 0),
  (5, 'Touhou Chireikiden - Hansoku Tantei Satori Vol. 6', 'ZUN', NULL, 100, 1500, '/image/6107cfeb71cde9bed116a8abedf002e0.jpg', 0),
  (6, 'Touhou Chireikiden - Hansoku Tantei Satori Vol. 7', 'ZUN', NULL, 100, 1500, '/image/5d8c565ebb732e50868d6b1a21c6b678.jpg', 0),
  (7, 'JoJo''s Bizzarre Adventure Part 7 - Steel Ball Run Vol. 1', 'Araki Hirohiko', '9784088736013', 100, 2500, '/image/a1c50444f4711bf4bf8de1b978f814c2.jpg', 50),
  (8, 'JoJo''s Bizzarre Adventure Part 7 - Steel Ball Run Vol. 2', 'Araki Hirohiko', '9784088736136', 100, 2500, '/image/eb7bc9dd412f2a32c2a80106b97424cc.jpg', 0),
  (9, 'JoJo''s Bizzarre Adventure Part 7 - Steel Ball Run Vol. 3', 'Araki Hirohiko', '9784088736730', 100, 2500, '/image/439099b74205ea299adf0fc5e49ad998.jpg', 0),
  (10, 'JoJo''s Bizzarre Adventure Part 7 - Steel Ball Run Vol. 4', 'Araki Hirohiko', '9784088736891', 100, 2500, '/image/186ff0b93b161badb8640c19f5ffef38.jpg', 0);
ALTER SEQUENCE "mangas_id_seq" RESTART WITH 11;

INSERT INTO users (id, name, address, email, username, password, is_admin) VALUES
  (1, 'admin', 'admin''s house', 'admin@admin.com', 'admin', '$2b$12$D3PkAVuo55KYdLms/xHYU.PbFard9Btqe2PXlLWBoIXM3aldtfKxa', true),
  (2, 'Cirno Baka', 'Misty Lake 123', 'cirno@gensokyo.com', 'cirno', '$2b$12$D3PkAVuo55KYdLms/xHYU.PbFard9Btqe2PXlLWBoIXM3aldtfKxa', false),
  (3, 'Kirisame Marisa', 'Forest of Magic 123', 'marisa@gensokyo.com', 'marisa', '$2b$12$D3PkAVuo55KYdLms/xHYU.PbFard9Btqe2PXlLWBoIXM3aldtfKxa', false),
  (4, 'Kawashiro Nitori', 'Yokai Mountain 123', 'nitori@kappa.com', 'nitori', '$2b$12$D3PkAVuo55KYdLms/xHYU.PbFard9Btqe2PXlLWBoIXM3aldtfKxa', false);
ALTER SEQUENCE "users_id_seq" RESTART WITH 3;

INSERT INTO user_carts (id, subtotal, user_id) VALUES
  (1, 0, 1),
  (2, 0, 2),
  (3, 0, 3),
  (4, 0, 4);
ALTER SEQUENCE "user_carts_id_seq" RESTART WITH 5;

COMMIT;

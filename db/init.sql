-- demo init
CREATE TABLE IF NOT EXISTS test_table(id serial primary key, name text);
INSERT INTO test_table(name) VALUES ('hello');

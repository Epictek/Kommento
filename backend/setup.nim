import db_sqlite

let db = open("comments.db", "", "", "comments")

db.exec(sql"""
CREATE TABLE user(
  id integer primary key,
  name varchar(30),
  email varchar(30),
  password varchar(255)
);
""")

db.exec(sql"""
CREATE TABLE domain(
  id integer primary key,
  domain varchar(63) not null,
  owner integer not null default 0,
  foreign key (owner) references user(id)
);
""")

db.exec(sql"""
CREATE TABLE thread(
  id interger primary key,
  url varchar(255) not null,
  title varchar(30),
  domain not null default 0,
  foreign key (domain) references domain(id)
);
""")

db.exec(sql"""
CREATE TABLE comment(
  id integer primary key,
  name varchar(30),
  email varchar(254),
  page varchar(32) not null,
  comment varchar(1000) not null,
  creation timestamp not null default (DATETIME('now')),
  ip inet not null,
  key varchar(100) not null,
  spam boolean not null default 0,
  replyTo integer,
  thread integer not null default 0,
  foreign key (thread) references thread(id)
);
""")

create table if not exists employee (
    id_employee serial primary key,
    name varchar (50) not null
);

create table if not exists role (
    id_role serial primary key,
    name varchar (50) not null
);

create table if not exists project (
    id_project serial primary key,
    name varchar (50) not null,
    scheduled_start_date timestamp,
    start_date timestamp,
    scheduled_end_date timestamp,
    end_date timestamp
);

create table if not exists stage (
    id_stage serial primary key,
    name varchar (50) not null
);

create table if not exists project_stage (
    id_project_stage serial primary key,
    id_project int,
    id_stage int,
    start_date timestamp,
    end_date timestamp
);

create table if not exists employee_project_role (
    id_employee_project_role serial primary key,
    id_employee int,
    id_project int,
    id_role int,
    start_date timestamp,
    end_date timestamp
);
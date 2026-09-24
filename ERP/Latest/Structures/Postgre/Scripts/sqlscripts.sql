<<
CREATE SEQUENCE IF NOT EXISTS "{{schemaName}}".librarybooksequence START WITH 100 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1
>>

<<
CREATE TABLE IF NOT EXISTS "{{schemaName}}"."librarybook" (
    "bookid" integer NOT NULL,
    "bookname" varchar(100),
    "authorname" varchar(100),
    "price" numeric(10,2),
    "publisheddate" date
)
>>

<<
CREATE INDEX idx_librarybook_author ON "{{schemaName}}".librarybook USING btree (authorname)
>>

<<
CREATE OR REPLACE FUNCTION "{{schemaName}}".librarycalculateprice(p_price numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN p_price * 1.10;
END;
$function$
>>

<<
CREATE OR REPLACE FUNCTION "{{schemaName}}".librarytriggerfunction()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    RAISE NOTICE 'A new book has been inserted.';
    RETURN NEW;
END;
$function$
>>

<<
CREATE TRIGGER libraryinserttrigger AFTER INSERT ON librarybook FOR EACH ROW EXECUTE FUNCTION librarytriggerfunction()
>>

<<
CREATE OR REPLACE VIEW "{{schemaName}}".librarybookview AS  SELECT librarybook.bookid,
    librarybook.bookname,
    librarybook.authorname,
    librarybook.price
   FROM librarybook;
>>

<<
DROP MATERIALIZED VIEW IF EXISTS "{{schemaName}}".librarybookmaterializedview
>>

<<
CREATE MATERIALIZED VIEW "{{schemaName}}".librarybookmaterializedview
AS
 SELECT librarybook.authorname,
    count(*) AS totalbooks,
    avg(librarybook.price) AS averageprice,
    sum(librarybook.price) AS totalprice
   FROM librarybook
  GROUP BY librarybook.authorname
WITH DATA
>>
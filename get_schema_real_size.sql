--Get Schema real size and also occupied space size in the DB
select x.code, 
        round(
          (
            (
                SELECT sum(NVL((num_rows*avg_row_len), 0)) 
                 FROM dba_tables
                 WHERE owner = x.code
            )
            +        
            (
                SELECT sum(NVL((leaf_blocks*8*1024), 0)) 
                 FROM dba_indexes
                 WHERE table_owner = x.code
                 AND owner = x.code
            )
            +
            (
                SELECT  sum(NVL(bytes,0)) 
                 FROM dba_segments s, dba_lobs l
                 WHERE s.owner = x.code
                 AND s.segment_type = 'LOBSEGMENT'
                 AND s.segment_name = l.segment_name
            ))/1024/1024/1024,2
        ) "actual_size_gb",
        (
               select 
                trunc(sum(bytes/1024/1024/1024),2) 
               from dba_segments
               where owner=x.code
        ) "occupied_size_gb"       
from (
    select upper('&schemaname') as SCHAMNAME from dual 
) x 
group by code;

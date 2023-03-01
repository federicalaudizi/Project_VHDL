library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
        port (i_clk: in std_logic;
              i_rst: in std_logic;
              i_start : in std_logic;
              i_w: in std_logic;
              o_z0 : out std_logic_vector(7 downto 0);
              o_z1: out std_logic_vector(7 downto 0);
              o_z2: out std_logic_vector(7 downto 0);
              o_z3: out std_logic_vector(7 downto 0);
              o_done: out std_logic;
              o_mem_addr : out std_logic_vector(15 downto 0);
              i_mem_data : in std_logic_vector(7 downto 0);
              o_mem_we: out std_logic;
              o_mem_en : out std_logic);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state_type is(
    RST,
    S0,    
    S1,
    S2
);

signal CURRENT_STATE, NEXT_STATE : state_type := RST;
signal mem_z0, mem_z1, mem_z2, mem_z3: std_logic_vector (7 downto 0) := "00000000";
signal out_channel: std_logic_vector (1 downto 0) := "00";
signal out_address: std_logic_vector (15 downto 0) := "0000000000000000";
signal prev_sig: std_logic_vector (7 downto 0) := "UUUUUUUU";

begin

process(i_clk, i_rst, i_start)

variable count: integer := 0;

    begin

        --NEXT_STATE <= RST;
        --o_z0 <= (others => '0');
        --o_z1 <= "00000000";
        --o_z2 <= "00000000";
        --o_z3 <= "00000000";
        --o_done <= '0';

        if(i_clk'event and i_clk = '1') then
                if(i_rst = '1') then 
                    CURRENT_STATE <= RST;
                else
                    CURRENT_STATE <= NEXT_STATE;
                end if;
        end if; 
            
        case CURRENT_STATE is 
            when RST =>
            
               o_mem_en <= '0';  --resettando tutte le variabili a zero (stato iniziale)
               o_done <= '0';
               out_channel <= "00";
               out_address <= "0000000000000000";
               o_z0 <= "00000000";
               o_z1 <= "00000000";
               o_z2 <= "00000000";
               o_z3 <= "00000000";
               mem_z0 <= "00000000";
               mem_z1 <= "00000000";
               mem_z2 <= "00000000";
               mem_z3 <= "00000000";
               count := 0;
                
               if(i_start = '1') then --faccio una transizione al prossimo stato quando start = 1
                  NEXT_STATE <= S1;
               else 
                  NEXT_STATE <= RST; --altrimenti rimango in questo stato
               end if; 
               -- NEXT_STATE <= S2;
             when S0 =>
               o_mem_en <= '0';  --resttando tutte le variabili a zero (stato iniziale)
               --o_done <= '0';
               out_channel <= "00";
               out_address <= "0000000000000000";
               --o_z0 <= "00000000";
               --o_z1 <= "00000000";
               --o_z2 <= "00000000";
               --o_z3 <= "00000000";
               count := 0;
                
               if(i_start = '1') then --faccio una transizione al prossimo stato quando start = 1
                  NEXT_STATE <= S1;
               else 
                  NEXT_STATE <= S0; --altrimenti rimango in questo stato
               end if;
             
             when S1 =>                                 -- in questo stato ricevo e salvo il canale d'uscita  
                o_mem_en <= '0';                        -- e l'indirizzo di memoria dal quale prendere il dato
                --o_z0 <= "00000000";
                --o_z1 <= "00000000";
                --o_z2 <= "00000000";
                --o_z3 <= "00000000";
                --o_done <= '0';
                if (i_start = '1') then
                    if (count = 0) then 
                        if (i_w = '1') then 
                            out_channel <= "10";
                        else 
                            out_channel <= "00";
                        end if;    
                    elsif (count = 1) then 
                        if (out_channel = "10" and i_w = '1') then 
                            out_channel <= "11";
                        elsif (out_channel = "10" and i_w = '0') then
                            out_channel <= "10";
                        elsif (out_channel = "00" and i_w = '1') then 
                            out_channel <= "01";
                        else
                            out_channel <= "00";
                        end if;
                    else
                       if (rising_edge(i_clk)) then 
                            out_address  <= out_address (14 downto 0) & i_w; 
                        end if;
                    end if;  
                    NEXT_STATE <= S1;      
               else 
                    o_mem_addr <= out_address;
                    NEXT_STATE <= S2;
               end if;
               count := count + 1; 
                 
            when S2 =>
                 o_mem_addr <= out_address;
                 o_mem_we <= '0'; --per fare richiesta di lettura
                 o_mem_en <= '1'; --per comunicare con la memoria  
                 
                 if (i_mem_data /= prev_sig) then
                     prev_sig <= i_mem_data;
                     if (out_channel = "00") then
                        mem_z0 <= i_mem_data;
                        o_z0 <= i_mem_data;
                        o_z1 <= mem_z1;
                        o_z2 <= mem_z2;
                        o_z3 <= mem_z3;
                     elsif (out_channel = "01") then 
                        mem_z1 <= i_mem_data;
                        o_z1 <= i_mem_data;
                        o_z0 <= mem_z0;
                        o_z2 <= mem_z2;
                        o_z3 <= mem_z3;
                     elsif (out_channel = "10") then 
                        mem_z2 <= i_mem_data;
                        o_z0 <= mem_z0;
                        o_z1 <= mem_z1;
                        o_z2 <= i_mem_data;
                        o_z3 <= mem_z3;
                     else 
                        mem_z3 <= i_mem_data;
                        o_z0 <= mem_z0;
                        o_z1 <= mem_z1;
                        o_z2 <= mem_z2;
                        o_z3 <= i_mem_data;
                     end if;
                     o_done <= '1';
                  else
                        o_z0 <= "00000000";
                        o_z1 <= "00000000";
                        o_z2 <= "00000000";
                        o_z3 <= "00000000";
                        o_done <= '0';
                  end if;   
                 
                 if (i_mem_data = prev_sig) then
                    NEXT_STATE <= S2;
                 elsif (i_start = '1') then 
                    count := 0;
                    out_address <= "0000000000000000";
                    o_mem_en <= '0';
                    NEXT_STATE <= S1;
                 else 
                    count := 0;
                    out_address <= "0000000000000000"; 
                    o_mem_en <= '0';
                    NEXT_STATE <= S0;
                 end if;  
            
            
            
            when others =>
                o_done <= '0';
                o_z0 <= "00000000";
                o_z1 <= "00000000";
                o_z2 <= "00000000";
                o_z3 <= "00000000";
        end case;
    end process;

end Behavioral;

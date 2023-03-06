LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY project_reti_logiche IS
   PORT (
      i_clk : IN STD_LOGIC;
      i_rst : IN STD_LOGIC;
      i_start : IN STD_LOGIC;
      i_w : IN STD_LOGIC;
      o_z0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      o_z1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      o_z2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      o_z3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      o_done : OUT STD_LOGIC;
      o_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      i_mem_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      o_mem_we : OUT STD_LOGIC;
      o_mem_en : OUT STD_LOGIC);
END project_reti_logiche;

ARCHITECTURE Behavioral OF project_reti_logiche IS

   TYPE state_type IS(
   RST,
   S0,
   S1,
   S2
   );

   SIGNAL CURRENT_STATE, NEXT_STATE : state_type := RST;
   SIGNAL mem_z0, mem_z1, mem_z2, mem_z3 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
   SIGNAL out_channel : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
   SIGNAL out_address : STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000000000";
   SIGNAL prev_sig : STD_LOGIC_VECTOR (7 DOWNTO 0) := "UUUUUUUU";

BEGIN

   PROCESS (i_clk, i_rst, i_start)
   BEGIN

      --NEXT_STATE <= RST;
      --o_z0 <= (others => '0');
      --o_z1 <= "00000000";
      --o_z2 <= "00000000";
      --o_z3 <= "00000000";
      --o_done <= '0';

      IF (i_clk'event AND i_clk = '1') THEN
         IF (i_rst = '1') THEN
            CURRENT_STATE <= RST;
         ELSE
            CURRENT_STATE <= NEXT_STATE;
         END IF;
      END IF;

      CASE CURRENT_STATE IS
         WHEN RST =>

            o_mem_en <= '0'; --resettando tutte le variabili a zero (stato iniziale)
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

            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= S1;
            ELSE
               NEXT_STATE <= RST; --altrimenti rimango in questo stato
            END IF;
            NEXT_STATE <= S2;
         WHEN S0 =>
            o_mem_en <= '0'; --resttando tutte le variabili a zero (stato iniziale)
            --o_done <= '0';
            out_channel <= "00";
            out_address <= "0000000000000000";
            --o_z0 <= "00000000";
            --o_z1 <= "00000000";
            --o_z2 <= "00000000";
            --o_z3 <= "00000000";

            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= S1;
            ELSE
               NEXT_STATE <= S0; --altrimenti rimango in questo stato
            END IF;

         WHEN S1 => -- in questo stato ricevo e salvo il canale d'uscita  
            o_mem_en <= '0'; -- e l'indirizzo di memoria dal quale prendere il dato
            --o_z0 <= "00000000";
            --o_z1 <= "00000000";
            --o_z2 <= "00000000";
            --o_z3 <= "00000000";
            --o_done <= '0';
            IF (i_start = '1') THEN
               NEXT_STATE <= S1;
            ELSE
               o_mem_addr <= out_address;
               NEXT_STATE <= S2;
            END IF;

         WHEN S2 =>
            o_mem_addr <= out_address;
            o_mem_we <= '0'; --per fare richiesta di lettura
            o_mem_en <= '1'; --per comunicare con la memoria  

            IF (i_mem_data /= prev_sig) THEN
               prev_sig <= i_mem_data;
               IF (out_channel = "00") THEN
                  mem_z0 <= i_mem_data;
                  o_z0 <= i_mem_data;
                  o_z1 <= mem_z1;
                  o_z2 <= mem_z2;
                  o_z3 <= mem_z3;
               ELSIF (out_channel = "01") THEN
                  mem_z1 <= i_mem_data;
                  o_z1 <= i_mem_data;
                  o_z0 <= mem_z0;
                  o_z2 <= mem_z2;
                  o_z3 <= mem_z3;
               ELSIF (out_channel = "10") THEN
                  mem_z2 <= i_mem_data;
                  o_z0 <= mem_z0;
                  o_z1 <= mem_z1;
                  o_z2 <= i_mem_data;
                  o_z3 <= mem_z3;
               ELSE
                  mem_z3 <= i_mem_data;
                  o_z0 <= mem_z0;
                  o_z1 <= mem_z1;
                  o_z2 <= mem_z2;
                  o_z3 <= i_mem_data;
               END IF;
               o_done <= '1';
            ELSE
               o_z0 <= "00000000";
               o_z1 <= "00000000";
               o_z2 <= "00000000";
               o_z3 <= "00000000";
               o_done <= '0';
            END IF;

            IF (i_mem_data = prev_sig) THEN
               NEXT_STATE <= S2;
            ELSIF (i_start = '1') THEN
               out_address <= "0000000000000000";
               o_mem_en <= '0';
               NEXT_STATE <= S1;
            ELSE
               out_address <= "0000000000000000";
               o_mem_en <= '0';
               NEXT_STATE <= S0;
            END IF;

         WHEN OTHERS =>
            o_done <= '0';
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
      END CASE;
   END PROCESS;

END Behavioral;
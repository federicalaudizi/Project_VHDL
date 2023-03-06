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
   S2,
   CH_0,
   CH_1,
   CH_2,
   CH_3
   );

   SIGNAL CURRENT_STATE, NEXT_STATE : state_type := RST;
   SIGNAL out_channel : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
   SIGNAL out_address : STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000000000";
   SIGNAL prev_mem_data : STD_LOGIC_VECTOR (7 DOWNTO 0) := "UUUUUUUU";
   SIGNAL mem_z0, mem_z1, mem_z2, mem_z3 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";

BEGIN

   PROCESS (i_clk, i_rst, i_start)

      VARIABLE count : INTEGER := 0;

   BEGIN

      NEXT_STATE <= RST;
      o_mem_en <= '1';
      o_z0 <= "00000000";
      o_z1 <= "00000000";
      o_z2 <= "00000000";
      o_z3 <= "00000000";
      o_mem_we <= '0';
      o_done <= '0';

      IF (i_clk'event AND i_clk = '1') THEN
         IF (i_rst = '1') THEN
            CURRENT_STATE <= RST;
         ELSE
            CURRENT_STATE <= NEXT_STATE;
         END IF;
      END IF;

      CASE CURRENT_STATE IS

         WHEN RST =>
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

            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= S1;
            ELSE
               NEXT_STATE <= RST; --altrimenti rimango in questo stato
            END IF;

         WHEN S0 =>
            out_channel <= "00";
            out_address <= "0000000000000000";
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            count := 0;

            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= S1;
            ELSE
               NEXT_STATE <= S0; --altrimenti rimango in questo stato
            END IF;

         WHEN S1 =>
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            IF (i_start = '1') THEN
               IF (count = 0) THEN
                  IF (i_w = '1') THEN
                     out_channel <= "10";
                  ELSE
                     out_channel <= "00";
                  END IF;
               ELSIF (count = 1) THEN
                  IF (out_channel = "10" AND i_w = '1') THEN
                     out_channel <= "11";
                  ELSIF (out_channel = "10" AND i_w = '0') THEN
                     out_channel <= "10";
                  ELSIF (out_channel = "00" AND i_w = '1') THEN
                     out_channel <= "01";
                  ELSE
                     out_channel <= "00";
                  END IF;
               ELSE
                  IF (rising_edge(i_clk)) THEN
                     out_address <= out_address (14 DOWNTO 0) & i_w;
                  END IF;
               END IF;
               NEXT_STATE <= S1;
            ELSE
               o_mem_addr <= out_address;
               NEXT_STATE <= S2;
            END IF;
            count := count + 1;

         WHEN S2 =>
            IF (i_mem_data /= prev_mem_data) THEN
               IF (out_channel = "00") THEN
                  NEXT_STATE <= CH_0;
               ELSIF (out_channel = "01") THEN
                  NEXT_STATE <= CH_1;
               ELSIF (out_channel = "10") THEN
                  NEXT_STATE <= CH_2;
               ELSE
                  NEXT_STATE <= CH_3;
               END IF;
            ELSE
               NEXT_STATE <= S2;
               o_z0 <= "00000000";
               o_z1 <= "00000000";
               o_z2 <= "00000000";
               o_z3 <= "00000000";
            END IF;

         WHEN CH_0 =>
            o_z0 <= i_mem_data;
            o_z1 <= mem_z1;
            o_z2 <= mem_z2;
            o_z3 <= mem_z3;
            o_done <= '1';
            mem_z0 <= i_mem_data;
            IF (i_start = '1') THEN
               count := 0;
               out_address <= "0000000000000000";
               prev_mem_data <= "UUUUUUUU";
               NEXT_STATE <= S1;
            ELSE
               count := 0;
               out_address <= "0000000000000000";
               prev_mem_data <= "UUUUUUUU";
               NEXT_STATE <= S0;
            END IF;

         WHEN CH_1 =>
            o_z0 <= mem_z0;
            o_z1 <= i_mem_data;
            o_z2 <= mem_z2;
            o_z3 <= mem_z3;
            o_done <= '1';
            mem_z1 <= i_mem_data;
            IF (i_start = '1') THEN
               count := 0;
               out_address <= "0000000000000000";
               prev_mem_data <= "UUUUUUUU";
               NEXT_STATE <= S1;
            ELSE
               count := 0;
               out_address <= "0000000000000000";
               prev_mem_data <= "UUUUUUUU";
               NEXT_STATE <= S0;
            END IF;

         WHEN CH_2 =>
            o_z0 <= mem_z0;
            o_z1 <= mem_z1;
            o_z2 <= i_mem_data;
            o_z3 <= mem_z3;
            o_done <= '1';
            mem_z2 <= i_mem_data;
            IF (i_start = '1') THEN
               count := 0;
               out_address <= "0000000000000000";
               prev_mem_data <= "UUUUUUUU";
               NEXT_STATE <= S1;
            ELSE
               count := 0;
               out_address <= "0000000000000000";
               prev_mem_data <= "UUUUUUUU";
               NEXT_STATE <= S0;
            END IF;

         WHEN CH_3 =>
            o_z0 <= mem_z0;
            o_z1 <= mem_z1;
            o_z2 <= mem_z2;
            o_z3 <= i_mem_data;
            o_done <= '1';
            mem_z3 <= i_mem_data;
            IF (i_start = '1') THEN
               count := 0;
               out_address <= "0000000000000000";
               prev_mem_data <= "UUUUUUUU";
               NEXT_STATE <= S1;
            ELSE
               count := 0;
               out_address <= "0000000000000000";
               prev_mem_data <= "UUUUUUUU";
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
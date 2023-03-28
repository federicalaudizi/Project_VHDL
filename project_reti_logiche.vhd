
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
   S0,
   S1,
   ADDR_0,
   FETCH,
   WRT,
   CH_0,
   CH_1,
   CH_2,
   CH_3
   );

   SIGNAL CURRENT_STATE : state_type := S0;
   SIGNAL out_channel : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
   SIGNAL out_address : STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000000000";
   SIGNAL mem_z0, mem_z1, mem_z2, mem_z3 : STD_LOGIC_VECTOR (7 DOWNTO 0);
   
BEGIN

   PROCESS (i_clk, i_rst)

   BEGIN
      o_mem_we <= '0';

      IF (rising_edge(i_clk)) THEN
         IF (i_rst = '1') THEN
            out_channel <= "00";
            out_address <= "0000000000000000";
            mem_z0 <= "00000000";
            mem_z1 <= "00000000";
            mem_z2 <= "00000000";
            mem_z3 <= "00000000";
            o_mem_en <= '0';
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            o_mem_addr <= "0000000000000000";
            o_done <= '0';

            CURRENT_STATE <= S0;

         ELSE
            CASE CURRENT_STATE IS

               WHEN S0 =>
                  o_done <= '0';
                  out_address <= "0000000000000000";
                  o_mem_en <= '0';
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";

                  IF (i_start = '1') THEN
                     IF (i_w = '1') THEN
                        out_channel <= "10";
                     ELSE
                        out_channel <= "00";
                     END IF;
                     CURRENT_STATE <= S1;
                  ELSE
                     out_channel <= "00";
                     CURRENT_STATE <= S0; --altrimenti rimango in questo stato
                  END IF;

               WHEN S1 =>
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";
                  o_done <= '0';
                  out_address <= "0000000000000000";
                  o_mem_en <= '0';
                  IF (out_channel = "10" AND i_w = '1') THEN
                     out_channel <= "11";
                  ELSIF (out_channel = "10" AND i_w = '0') THEN
                     out_channel <= "10";
                  ELSIF (out_channel = "00" AND i_w = '1') THEN
                     out_channel <= "01";
                  ELSE
                     out_channel <= "00";
                  END IF;
                  CURRENT_STATE <= ADDR_0;

               WHEN ADDR_0 =>
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";
                  o_done <= '0';
                  IF (i_start = '1') THEN
                     out_address(15 DOWNTO 0) <= out_address(14 DOWNTO 0) & i_w;                   
                     CURRENT_STATE <= ADDR_0;
                  ELSE
                     o_mem_addr <= out_address;
                     o_mem_en <= '1';
                     CURRENT_STATE <= FETCH; 
                  END IF;

               WHEN FETCH =>               
                   CURRENT_STATE <= WRT;
                 
               WHEN WRT =>
                  o_done <= '1';
                  IF (out_channel = "00") THEN
                        o_z0 <= i_mem_data;
                        o_z1 <= mem_z1;
                        o_z2 <= mem_z2;
                        o_z3 <= mem_z3;
                        CURRENT_STATE <= CH_0;
                     ELSIF (out_channel = "01") THEN
                        o_z0 <= mem_z0;
                        o_z1 <= i_mem_data;
                        o_z2 <= mem_z2;
                        o_z3 <= mem_z3;
                        CURRENT_STATE <= CH_1;
                     ELSIF (out_channel = "10") THEN
                        o_z0 <= mem_z0;
                        o_z1 <= mem_z1;
                        o_z2 <= i_mem_data;
                        o_z3 <= mem_z3;
                        CURRENT_STATE <= CH_2;
                     ELSE
                        o_z0 <= mem_z0;
                        o_z1 <= mem_z1;
                        o_z2 <= mem_z2;
                        o_z3 <= i_mem_data;
                        CURRENT_STATE <= CH_3;
                     END IF;
                     
               WHEN CH_0 =>
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";
                  o_mem_en <= '1';
                  o_mem_we <= '0';
                  out_channel <= "00";
                  o_done <= '0';
                  mem_z0 <= i_mem_data;
                  IF (i_start = '1') THEN
                     CURRENT_STATE <= S1;
                  ELSE
                     CURRENT_STATE <= S0;
                  END IF;

               WHEN CH_1 =>
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";
                  o_mem_en <= '1';
                  out_channel <= "00";
                  mem_z1 <= i_mem_data;
                  o_mem_we <= '0';
                  o_done <= '0';
                  IF (i_start = '1') THEN
                     CURRENT_STATE <= S1;
                  ELSE
                     CURRENT_STATE <= S0;
                  END IF;

               WHEN CH_2 =>
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";
                  o_mem_en <= '1';
                  mem_z2 <= i_mem_data;
                  o_mem_we <= '0';
                  out_channel <= "00";
                  o_done <= '0';
                  IF (i_start = '1') THEN
                     CURRENT_STATE <= S1;
                  ELSE
                     CURRENT_STATE <= S0;
                  END IF;

               WHEN CH_3 =>
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";
                  o_mem_en <= '1';
                  mem_z3 <= i_mem_data;
                  o_mem_we <= '0';
                  o_done <= '0';
                  out_channel <= "00";
                  IF (i_start = '1') THEN
                     CURRENT_STATE <= S1;
                  ELSE
                     CURRENT_STATE <= S0;
                  END IF;

               WHEN OTHERS =>
                  o_mem_en <= '1';
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";
                  out_channel <= "00";
                  out_address <= "0000000000000000";
                  mem_z0 <= "00000000";
                  mem_z1 <= "00000000";
                  mem_z2 <= "00000000";
                  mem_z3 <= "00000000";
                  o_done <= '0';
                  o_mem_addr <= "0000000000000000";
                  CURRENT_STATE <= S0;
            END CASE;
         END IF;
      END IF;
   END PROCESS;

END Behavioral;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
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
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    TYPE state_type IS(
        RST,
        S0,
        CH_0,
        CH_1,
        ADDR_0,
        ADDR_1,
        ADDR_2,
        ADDR_3,
        ADDR_4,
        ADDR_5,
        ADDR_6,
        ADDR_7,
        ADDR_8,
        ADDR_9,
        ADDR_10,
        ADDR_11,
        ADDR_12,
        ADDR_13,
        ADDR_14,
        ADDR_15,
        WRT_1,
        OUT_0,
        OUT_1,
        OUT_2,
        OUT_3
    );
    
    SIGNAL CURRENT_STATE, NEXT_STATE : state_type := RST;
    SIGNAL out_ch_0, out_ch_1 : STD_LOGIC := '0';
    SIGNAL out_channel : STD_LOGIC_VECTOR (1 downto 0);
    SIGNAL out_addr_0 : STD_LOGIC;
    SIGNAL out_address : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL prev_mem_data : STD_LOGIC_VECTOR (7 DOWNTO 0) := "UUUUUUUU";
    SIGNAL mem_z0, mem_z1, mem_z2, mem_z3 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";

begin
    PROCESS (i_clk, i_rst)
    BEGIN
        o_done <= '0';
        o_z0 <= "00000000";
        o_z1 <= "00000000";
        o_z2 <= "00000000";
        o_z3 <= "00000000";
        o_mem_we <= '0';

        IF (i_clk'event AND i_clk = '1') THEN
          IF (i_rst = '1') THEN
             CURRENT_STATE <= RST;
          ELSE
             CURRENT_STATE <= NEXT_STATE;
          END IF;
        END IF;
      
      CASE CURRENT_STATE IS
         WHEN RST =>
            out_ch_0 <= '0';
            out_ch_1 <= '0';
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
               NEXT_STATE <= CH_0;
            ELSE
               NEXT_STATE <= RST; --altrimenti rimango in questo stato
            END IF;
          
         WHEN S0 =>
            out_ch_0 <= '0';
            out_ch_1 <= '0';
            out_address <= "0000000000000000";
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= CH_0;
            ELSE
               NEXT_STATE <= S0; --altrimenti rimango in questo stato
            END IF;
            
         WHEN CH_0 =>
            out_address <= "0000000000000000";
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            --IF (rising_edge(i_clk)) THEN
                IF (i_w = '1') THEN
                      out_ch_0 <= '1';
                ELSE
                     out_ch_0 <= '0';
                END IF;
            --END IF;
            NEXT_STATE <= CH_1;
            
         WHEN CH_1 =>
            out_address <= "0000000000000000";
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            out_ch_1 <= i_w;
            --out_channel <= out_ch_0 & out_ch_1;            
            
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_0;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;
            
         WHEN ADDR_0 =>
            out_addr_0 <= i_w;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_1;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;
            
         WHEN ADDR_1 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_2;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;
            
         WHEN ADDR_2 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_3;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF; 
            
         WHEN ADDR_3 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_4;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_4 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_5;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_5 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_6;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_6 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_7;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_7 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_8;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_8 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_9;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_9 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_10;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_10 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_11;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_11 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_12;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_12 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_13;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_13 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_14;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_14 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
               
            IF (i_start = '1') THEN --faccio una transizione al prossimo stato quando start = 1
               NEXT_STATE <= ADDR_15;
            ELSE
               NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato
            END IF;        
                   
         WHEN ADDR_15 =>
            IF (rising_edge(i_clk)) THEN
               out_address <= out_address (14 DOWNTO 0) & i_w;
            END IF;
            NEXT_STATE <= WRT_1; --altrimenti rimango in questo stato            
         
         WHEN WRT_1 =>
            o_mem_addr <= out_address;
            o_mem_en <= '1';
            IF (i_mem_data /= prev_mem_data) THEN
               IF (out_channel = "00") THEN
                  NEXT_STATE <= OUT_0;
               ELSIF (out_channel = "01") THEN
                  NEXT_STATE <= OUT_1;
               ELSIF (out_channel = "10") THEN
                  NEXT_STATE <= OUT_2;
               ELSE
                  NEXT_STATE <= OUT_3;
               END IF;
            ELSE
               NEXT_STATE <= WRT_1;
            END IF;
         
         WHEN OUT_0 =>
            o_z0 <= i_mem_data;
            o_z1 <= mem_z1;
            o_z2 <= mem_z2;
            o_z3 <= mem_z3;
            o_done <= '1';
            mem_z0 <= i_mem_data;
            out_address <= "0000000000000000";
            prev_mem_data <= "UUUUUUUU";
            IF (i_start = '1') THEN
               NEXT_STATE <= CH_0;
            ELSE
               NEXT_STATE <= S0;
            END IF;

         WHEN OUT_1 =>
            o_z0 <= mem_z0;
            o_z1 <= i_mem_data;
            o_z2 <= mem_z2;
            o_z3 <= mem_z3;
            o_done <= '1';
            mem_z1 <= i_mem_data;
            out_address <= "0000000000000000";
            prev_mem_data <= "UUUUUUUU";            
            IF (i_start = '1') THEN
               NEXT_STATE <= CH_0;
            ELSE
               NEXT_STATE <= S0;
            END IF;

         WHEN OUT_2 =>
            o_z0 <= mem_z0;
            o_z1 <= mem_z1;
            o_z2 <= i_mem_data;
            o_z3 <= mem_z3;
            o_done <= '1';
            mem_z2 <= i_mem_data;
            out_address <= "0000000000000000";
            prev_mem_data <= "UUUUUUUU";
            IF (i_start = '1') THEN
               NEXT_STATE <= CH_0;
            ELSE
               NEXT_STATE <= S0;
            END IF;

         WHEN OUT_3 =>
            o_z0 <= mem_z0;
            o_z1 <= mem_z1;
            o_z2 <= mem_z2;
            o_z3 <= i_mem_data;
            o_done <= '1';
            mem_z3 <= i_mem_data;
            IF (i_start = '1') THEN
               NEXT_STATE <= CH_0;
            ELSE
               NEXT_STATE <= S0;
            END IF;

         WHEN OTHERS =>
            o_done <= '0';
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            NEXT_STATE <= RST;
 
        END CASE;
      END PROCESS;

end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is

type mem_type is array (8 downto 0) of std_logic_vector(7 downto 0);

type state_type is(
    
    RST,
    WZ0,    --leggo WZ address e addr RAM(0) to RAM(8)
    WZ1,
    WZ2,
    WZ3,
    WZ4,
    WZ5,
    WZ6,
    WZ7,
    ADDR,
    WRITE,  -- calcolo e scrivo in mem
    DONE_ONE,    -- metto o_done = 1, aspetto start=0 per tornare in RST
    DONE_ZERO,
    WAIT_STATE    --metto done = 0 e attendo start = 1 o rst = 1
    
);

signal CURRENT_STATE, NEXT_STATE : state_type := RST; --Variabil che tengono traccia dei cambiamenti di stato
signal mem : mem_type := (others=>(others=>'0'));

begin


process(i_clk, i_rst, i_start)

constant WZ_BIT : std_logic := '1';
variable WZ_NUM : std_logic_vector(2 downto 0) := "000";
variable WZ_OFFSET : std_logic_vector(3 downto 0);

begin
    --fixing "inferred latch"
    NEXT_STATE <= RST;
    o_en <= '1';
    o_done <= '0';
    o_we <= '0';
    o_data <= "00000000";
    WZ_OFFSET := "0000";
        
    
    if(i_clk'event and i_clk = '1') then
        if(i_rst = '1') then    --sincrono
            CURRENT_STATE <= RST;
        else
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end if; 
    
    
case CURRENT_STATE is 

    when RST =>
        o_done <= '0';
        o_en <= '1';
        o_we <= '0';
        o_address <= "0000000000000000";    --richiedo WZ0
        
        if(i_start = '1') then
            NEXT_STATE <= WZ0;
        else 
            NEXT_STATE <= RST;
        end if;
                
        
    when WZ0 => 
        --read ram
        mem(0) <= i_data;   --salvo WZ0
        o_address <= "0000000000000001";    --richiedo WZ1

        if(i_start = '1') then
            NEXT_STATE <= WZ1;
        else 
            NEXT_STATE <= WZ0;
        end if;
        
    
    when WZ1 =>
        
        mem(1) <= i_data;
        o_address <= "0000000000000010";

    
        if(i_start = '1') then
            NEXT_STATE <= WZ2;
        else 
            NEXT_STATE <= WZ1;
        end if;
    
    

    when WZ2 =>
    
        mem(2) <= i_data;
        o_address <= "0000000000000011";

        if(i_start = '1') then
            NEXT_STATE <= WZ3;
        else 
            NEXT_STATE <= WZ2;
        end if;

    when WZ3 =>

        mem(3) <= i_data;
        o_address <= "0000000000000100";
    
        if(i_start = '1') then
            NEXT_STATE <= WZ4;
        else 
            NEXT_STATE <= WZ3;
        end if;
    
    when WZ4 =>

        mem(4) <= i_data;
        o_address <= "0000000000000101";

        if(i_start = '1') then
            NEXT_STATE <= WZ5;
        else 
            NEXT_STATE <= WZ4;
        end if;
    
    when WZ5 =>
    
        mem(5) <= i_data;
        o_address <= "0000000000000110";

        if(i_start = '1') then
            NEXT_STATE <= WZ6;
        else 
            NEXT_STATE <= WZ5;
        end if;
    
    when WZ6 =>

        mem(6) <= i_data;
        o_address <= "0000000000000111";
    
        if(i_start = '1') then
            NEXT_STATE <= WZ7;
        else 
            NEXT_STATE <= WZ6;
        end if;
    
    when WZ7 =>
        mem(7) <= i_data;
        o_address <= "0000000000001000";    
        
        if(i_start = '1') then
            NEXT_STATE <= ADDR;
        else 
            NEXT_STATE <= WZ7;
        end if;
    
    when ADDR =>
        o_en <= '1';
        
        mem(8) <= i_data;   --salvo addr
        o_address <= "0000000000001001"; --salva a indirizzo RAM(9), per WRITE
        
               
        if(i_start = '1') then
            NEXT_STATE <= WRITE;
        else
            NEXT_STATE <= ADDR;
        end if;
    
    when WRITE =>   -- calculate o_data and write ram through o_address
        
        o_address <= "0000000000001001";   
        o_we <= '1';    --permetto scrittura per stato successivo WRITE
        
        if(mem(8) = mem(0)) then
            o_data <= '1' & "000" & "0001";
        elsif(mem(8) = mem(0) + "00000001") then
            o_data <= '1' & "000" & "0010";
        elsif(mem(8) = mem(0) + "00000010") then
            o_data <= '1' & "000" & "0100";
        elsif(mem(8) = mem(0) + "00000011") then
            o_data <= '1' & "000" & "1000";
        --WZ1
        elsif(mem(8) = mem(1)) then
            o_data <= '1' & "001" & "0001";
        elsif(mem(8) = mem(1) + "00000001") then
            o_data <= '1' & "001" & "0010";
        elsif(mem(8) = mem(1) + "00000010") then
            o_data <= '1' & "001" & "0100";
        elsif(mem(8) = mem(1) + "00000011") then
            o_data <= '1' & "001" & "1000";
        --WZ2
        elsif(mem(8) = mem(2)) then
           o_data <= '1' & "010" & "0001";
        elsif(mem(8) = mem(2) + "00000001") then
            o_data <= '1' & "010" & "0010";
        elsif(mem(8) = mem(2) + "00000010") then
            o_data <= '1' & "010" & "0100";
        elsif(mem(8) = mem(2) + "00000011") then
           o_data <= '1' & "010" & "1000";
        --WZ3
        elsif(mem(8) = mem(3)) then
            o_data <= '1' & "011" & "0001";
        elsif(mem(8) = mem(3) + "00000001") then
            o_data <= '1' & "011" & "0010";
        elsif(mem(8) = mem(3) + "00000010") then
            o_data <= '1' & "011" & "0100";
        elsif(mem(8) = mem(3) + "00000011") then
            o_data <= '1' & "011" & "1000";
        --WZ4
        elsif(mem(8) = mem(4)) then
            o_data <= '1' & "100" & "0001";
        elsif(mem(8) = mem(4) + "00000001") then
            o_data <= '1' & "100" & "0010";
        elsif(mem(8) = mem(4) + "00000010") then
            o_data <= '1' & "100" & "0100";
        elsif(mem(8) = mem(4) + "00000011") then
            o_data <= '1' & "100" & "1000";
        --WZ5
        elsif(mem(8) = mem(5)) then
            o_data <= '1' & "101" & "0001";
        elsif(mem(8) = mem(5) + "00000001") then
            o_data <= '1' & "101" & "0010";
        elsif(mem(8) = mem(5) + "00000010") then
            o_data <= '1' & "101" & "0100";
        elsif(mem(8) = mem(5) + "00000011") then
            o_data <= '1' & "101" & "1000";
        --WZ6
        elsif(mem(8) = mem(6)) then
            o_data <= '1' & "110" & "0001";
        elsif(mem(8) = mem(6) + "00000001") then
            o_data <= '1' & "110" & "0010";
        elsif(mem(8) = mem(6) + "00000010") then
            o_data <= '1' & "110" & "0100";
        elsif(mem(8) = mem(6) + "00000011") then
            o_data <= '1' & "110" & "1000";
        --WZ7
        elsif(mem(8) = mem(7)) then
            o_data <= '1' & "111" & "0001";
        elsif(mem(8) = mem(7) + "00000001") then
            o_data <= '1' & "111" & "0010";
        elsif(mem(8) = mem(7) + "00000010") then
            o_data <= '1' & "111" & "0100";
        elsif(mem(8) = mem(7) + "00000011") then
            o_data <= '1' & "111" & "1000";
        --non appartiene a WZ
        else
            o_data <= mem(8);
        end if;            
 
        
        if(i_start = '1') then
            NEXT_STATE <= DONE_ONE;
        else 
            NEXT_STATE <= WRITE;
        end if;
    
    when DONE_ONE =>
        o_address <= "0000000000000000";    
        --o_data <= "";
        o_we <= '0';
        o_done <= '1';
        o_en <= '0'; -- spengo accesso memoria just in case
        --found := '0';
        
        if(i_start = '1') then  --edited
            NEXT_STATE <= DONE_ZERO;
        else 
            NEXT_STATE <= DONE_ONE;
        end if;


    when DONE_ZERO =>
        o_address <= "0000000000000000";    
        --o_done <= '0';
        o_en <= '0';

        if(i_start = '0') then
            o_done <= '0';  --edited
            NEXT_STATE <= WAIT_STATE;
        else
            o_done <= '1';
            NEXT_STATE <= DONE_ZERO;
        end if;
        
        

        when WAIT_STATE =>
        o_address <= "0000000000001000";   
        --o_done <= '0';
        o_en <= '1';

        if(i_start = '1') then
            --o_done <= '0';  --edited but useless
            NEXT_STATE <= ADDR;  --leggo nuovo addr
        else
            NEXT_STATE <= WAIT_STATE;
        end if;

    
    when others =>
        o_address <= "0000000000000000";    
    
end case;
end process;
end Behavioral;
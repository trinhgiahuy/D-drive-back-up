-------------------------------------------------------------------------------
-- Title      : Testbench for traffic lights FSMs
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_traffic_light.vhd
-- Author     : kulmala3
-- Company    : 
-- Last update: 2013-01-23
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Instantiates traffic light FSM
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 12.10.2007  1.0      AK      Created
-- 2011/02/01  1.0      ege	Clarified
-- 2013-01-23  1.0      ege	Clarified
-------------------------------------------------------------------------------
-- Copyright (c) 2007 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.traffic_light_pkg.all;


-- Testbench needs no inputr nor outputs
entity tb_traffic_light is
end tb_traffic_light;



architecture tb of tb_traffic_light is

  -- Constants
  constant period_c        : time    := 10 ns;
  constant yellow_length_c : integer := 5;  -- clk cycles to show yellow light


  component traffic_light
    generic (
      yellow_length_g : integer);    
    port (
      clk          : in  std_logic;
      rst_n        : in  std_logic;
      red_req_in   : in  std_logic;
      green_req_in : in  std_logic;
      r_y_g_out    : out std_logic_vector(n_colors_c-1 downto 0));
  end component;

  -- Signals mapped DUV ports
  signal   clk              : std_logic := '0';
  signal   rst_n            : std_logic;
  signal   red_req_to_duv   : std_logic;
  signal   green_req_to_duv : std_logic;
  signal   r_y_g_from_duv   : std_logic_vector(n_colors_c-1 downto 0);



  -- Helper signals for stimulus
  type   in_states is (show_green, req_red, show_red, req_green);
  signal in_ctrl_r : in_states;

  constant cnt_high_c : integer := 50;  -- max cycles to show a light
  signal color_cnt_r  : integer;        -- range 0 to cnt_high_c-1;
  
  -- Mod counter changes the timing of requests gradually (kind of
  -- pseudo-random timing)
  signal   mod_cnt_r      : integer;    -- range 0 to cnt_high_c-1;

  -- Occasionally tb requests both red and green simultaneously
  signal   req_opposite_r : std_logic;

  
  -- Tmp signals for automated checking of color change
  signal prev_color_r    : std_logic_vector(n_colors_c-1 downto 0);
  signal   yellow_cnt_r   : integer;    -- range 0 to yellow_length_c*2;

  
begin  -- tb

  -- Component instantiation
  DUV : traffic_light
    generic map (
      yellow_length_g => yellow_length_c)    
    port map (
      clk          => clk,
      rst_n        => rst_n,
      red_req_in   => red_req_to_duv,
      green_req_in => green_req_to_duv,
      r_y_g_out    => r_y_g_from_duv
      );


  -- Generate clock and reset
  clk   <= not clk  after period_c/2;
  rst_n <= '0', '1' after 2* period_c;
  

  --
  -- Generate 2 request signals for DUV. That requires few counters and other
  -- stuff. Sometimes, TB requests both green and red which is kind of illegal
  -- but done on pupose. On those cases, the traffic light should go to red
  -- which is safer.
  --
  gen_input : process (clk, rst_n)
  begin  -- process input
    
    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- Stimulus
      red_req_to_duv   <= '0';
      green_req_to_duv <= '0';

      -- Helper signals
      in_ctrl_r        <= req_green;    -- init state
      color_cnt_r      <= 0;
      mod_cnt_r        <= cnt_high_c-1;
      req_opposite_r   <= '0';

      
    elsif clk'event and clk = '1' then  -- rising clock edge

      case in_ctrl_r is
        -- FSM goes in a loop without any branching
        
        when req_green =>
          -- Keep requesting green light until it is lit
          green_req_to_duv <= '1';
          if r_y_g_from_duv = green_color_c then
            in_ctrl_r        <= show_green;
            green_req_to_duv <= '0';
          end if;
          -- Moreover, test what DUV does if opposite colors (green+red) are
          -- requested at the same time
          if req_opposite_r = '1' and red_req_to_duv = '0' then
            red_req_to_duv <= '1';
            in_ctrl_r      <= show_green;
          end if;

        when show_green =>
          -- Wait by incrementing a counter until it overflows to 0
          if (color_cnt_r+1) mod (mod_cnt_r+1) = 0 then
            in_ctrl_r   <= req_red;
            mod_cnt_r   <= incr(mod_cnt_r, cnt_high_c-1);
            color_cnt_r <= 0;
          else
            color_cnt_r <= incr(color_cnt_r, cnt_high_c-1);
          end if;

        when req_red =>
          -- Keep requesting red light until it tis lit
          red_req_to_duv <= '1';
          if r_y_g_from_duv = red_color_c then
            in_ctrl_r      <= show_red;
            red_req_to_duv <= '0';
          end if;

        when show_red =>
          -- Wait by incrementing a counter until it overflows to 0
          if (color_cnt_r+1) mod (mod_cnt_r+1) = 0 then
            in_ctrl_r      <= req_green;
            req_opposite_r <= not req_opposite_r; -- toggle
            mod_cnt_r      <= incr(mod_cnt_r, cnt_high_c-1);
            color_cnt_r    <= 0;
          else
            color_cnt_r <= incr(color_cnt_r, cnt_high_c-1);
          end if;
          
        when others => null;
      end case;
    end if;
  end process gen_input;

  
  --
  -- Check the response from DUV
  --
  chk_output : process (clk, rst_n)
  begin  -- process output

    if rst_n = '0' then                 -- asynchronous reset (active low)

      yellow_cnt_r <= 0;
      prev_color_r  <= red_color_c;

      
    elsif clk'event and clk = '1' then  -- rising clock edge
      
      if r_y_g_from_duv = yellow_color_c then
        yellow_cnt_r <= incr(yellow_cnt_r, yellow_length_c*2);
      else
        yellow_cnt_r <= 0;
      end if;

      

      if yellow_cnt_r > yellow_length_c then
        assert false report "Yellow=1 too long" severity note;
      end if;

      if yellow_cnt_r = yellow_length_c+1 then
        -- Now the color should have changed by now
        if red_req_to_duv = '1' then
          assert r_y_g_from_duv = red_color_c report "not red, should be" severity error;
        else
          assert r_y_g_from_duv = green_color_c report "not green, should be" severity error;
        end if;
        
      end if;

      
      if prev_color_r = green_color_c and r_y_g_from_duv = red_color_c then
        assert false report "Straight change from green to red" severity error;
      end if;

      
      if prev_color_r = red_color_c and r_y_g_from_duv = green_color_c then
        assert false report "Straight change from red to green" severity error;
      end if;

      prev_color_r <= r_y_g_from_duv;
      
    end if;
  end process chk_output;


end tb;


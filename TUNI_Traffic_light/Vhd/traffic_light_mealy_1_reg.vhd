-------------------------------------------------------------------------------
-- Title      : Traffic light
-- Project    : Course material for TKT-1212 Digitaalijärjestelmien toteutus
-------------------------------------------------------------------------------
-- File       : traffic_light.vhd
-- Author     : Ari Kulmala
-- Created    : 12.10.2007
-- Last update: 2013-01-23
-- Description: Each light is shown a given amount of time
--              Mealy machine with 1 process (sync): ns/ps/out
--              Registered output
--              
-------------------------------------------------------------------------------
-- Copyright (c) 2007 Ari Kulmala
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 12.10.2007  1.0      AK      Created
-- 2011/02/01  1.1      ES      Beautifying things
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.traffic_light_pkg.all;

entity traffic_light is
  generic (
    yellow_length_g : integer := 10
    );
  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    -- Requests are active until the shown color is right (specification)
    red_req_in   : in  std_logic;       -- request a change to red
    green_req_in : in  std_logic;       -- request a change to green
    r_y_g_out    : out std_logic_vector(n_colors_c-1 downto 0)
    );

end traffic_light;

architecture rtl_mealy_1_reg of traffic_light is

  -- Enumerate possible states with human readable names
  type states_type is (red, yellow, green);
  signal curr_state_r : states_type;

  -- Timer for showing yellow for appropriate time period
  signal yellow_cnt_r : integer range 0 to yellow_length_g-1;


  
begin  -- rtl_mealy_1_reg


  -- The only process handles the state changes as well as output.
  -- Hence, output will be registered.It will change simultaneously with
  -- curr_state_r in this example.
  single : process (clk, rst_n)
  begin  -- process single
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
      curr_state_r <= red;              -- init state
      yellow_cnt_r <= 0;
      r_y_g_out    <= red_color_c;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- FSM always checks what is the current state
      -- Here that is done with case-clause, which is the common way.
      -- However, if-elsif is pretty much the same.
      case curr_state_r is

        
        when red =>
          if green_req_in = '1' then
            curr_state_r <= yellow;
            yellow_cnt_r <= 0;
            -- Turn on yellow already here due to output register
            r_y_g_out    <= yellow_color_c;  
          else
            r_y_g_out <= red_color_c;
            -- By default, curr_state_r keeps value if not assigned a new
          end if;

          
        when yellow =>
          if yellow_cnt_r = yellow_length_g-1 then
            -- It's time to change the light
            yellow_cnt_r <= 0;

            if green_req_in = '1' and red_req_in = '0' then
              r_y_g_out    <= green_color_c;
              curr_state_r <= green;
            else
              r_y_g_out    <= red_color_c;
              curr_state_r <= red;
            end if;
            
          else
            yellow_cnt_r <= yellow_cnt_r+1;
          end if;

          
        when green =>
          if red_req_in = '1' then
            curr_state_r <= yellow;
            yellow_cnt_r <= 0;
            r_y_g_out    <= yellow_color_c;
          else
            -- By default, signals keep value if not assigned a new
            r_y_g_out <= green_color_c;
          end if;

          -- when others => null;
          -- Our own data type is fully covered, thus no need for others
          -- However, it is ok to keep it here anyway, that's not an error
      end case;
    end if;
  end process single;

end rtl_mealy_1_reg;

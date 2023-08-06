-------------------------------------------------------------------------------
-- Title      : Traffic light
-- Project    : Course material for TKT-1212 Digitaalijärjestelmien toteutus
-------------------------------------------------------------------------------
-- File       : traffic_light_mealy_2b_noreg.vhd
-- Author     : Ari Kulmala
-- Created    : 12.10.2007
-- Last update: 2011/02/01
-- Description: Each light is shown a given amount of time
--              Mealy machine with 2 processes: ps, ns/out
--              Output is _not_ registered
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
    yellow_length_g : integer := 0
    );
  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    -- requests are active until the shown color is right (specification)
    red_req_in   : in  std_logic;       -- request a change to red
    green_req_in : in  std_logic;       -- request a change to green
    r_y_g_out    : out std_logic_vector(n_colors_c-1 downto 0)
    );

end traffic_light;

architecture rtl_mealy_2b_noreg of traffic_light is

  -- Enumerate possible states with human readable names
  type states_type is (red, yellow, green);
  signal curr_state_r : states_type;
  signal next_state   : states_type;

  -- Timer for showing yellow for appropriate time period
  signal yellow_cnt_r : integer range 0 to yellow_length_g-1;

  
begin  -- rtl


  -- 1. process handles the registers (state_r and counter)
  sync_ps : process (clk, rst_n)
  begin  -- process sync_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      curr_state_r <= red;              -- init state
      yellow_cnt_r <= 0;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      curr_state_r <= next_state;

      case curr_state_r is

        when yellow =>
          if yellow_cnt_r = yellow_length_g-1 then
            -- It's time to change the light
            yellow_cnt_r <= 0;
          else
            yellow_cnt_r <= yellow_cnt_r+1;
          end if;

        when others =>
          yellow_cnt_r <= 0;
      end case;
      
    end if;
  end process sync_ps;



  
  -- 2. Process handles the comb logic for next state and output
  comb_ns_output : process (curr_state_r, green_req_in,
                            red_req_in, yellow_cnt_r)
  begin  -- process next_state
    case curr_state_r is
      
      when red =>

        if green_req_in = '1' then
          next_state <= yellow;
        else
          next_state <= red;
        end if;
        
        if green_req_in = '1' and red_req_in = '0' then
          -- This kind of condition creates combinatorial path
          -- from input to output (=Mealy).
          r_y_g_out <= yellow_color_c;
        else
          r_y_g_out <= red_color_c;
        end if;

        
      when yellow =>
        
        if yellow_cnt_r = yellow_length_g-1 then
          -- It's time to change the light
          -- Note the duplicated condition! (Similar is also in sync process)

          if green_req_in = '1' and red_req_in = '0' then
            next_state <= green;
            r_y_g_out  <= green_color_c;
          else
            next_state <= red;
            r_y_g_out  <= red_color_c;
          end if;
        else
          next_state <= yellow;
          r_y_g_out <= yellow_color_c;
        end if;

        
      when green =>
        if red_req_in = '1' then
          next_state <= yellow;
          r_y_g_out  <= yellow_color_c;
        else
          next_state <= green;
          r_y_g_out <= green_color_c;
        end if;
        -- no when others since case is unambigous
    end case;
  end process comb_ns_output;
  
end rtl_mealy_2b_noreg;

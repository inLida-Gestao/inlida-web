// file: supabase/functions/get-projected-births-by-category/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.44.0";

// Configuração de CORS (Obrigatório, conforme sua regra)
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Edge Function para buscar Projeções de Parto
serve(async (req) => {
  // 1. Tratamento de requisições OPTIONS para CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // A função só deve responder a GET
  if (req.method !== 'GET') {
    return new Response(
      JSON.stringify({ ok: false, error: 'Método não permitido. Use GET.' }),
      { status: 405, headers: { 'Content-Type': 'application/json', ...corsHeaders } }
    );
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // 2. Extrair os parâmetros da URL Query String
    const url = new URL(req.url);
    const inicio = url.searchParams.get('inicio');
    const fim = url.searchParams.get('fim');
    const idPropriedade = url.searchParams.get('idPropriedade');

    if (!inicio || !fim || !idPropriedade) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Parâmetros de URL: "inicio", "fim" e "idPropriedade" são obrigatórios.' }),
        { status: 400, headers: { 'Content-Type': 'application/json', ...corsHeaders } }
      );
    }
    
    // 3. Chamar a NOVA função RPC do PostgreSQL para Projeção
    const { data, error } = await supabaseClient.rpc('get_projected_births_by_category_data', {
        id_propriedade_param: idPropriedade,
        inicio_param: inicio,
        fim_param: fim,
    });

    if (error) {
      console.error('Erro na consulta ao banco de dados:', error);
      return new Response(
        JSON.stringify({ ok: false, error: 'Erro ao buscar dados de projeção de partos: ' + error.message }),
        { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders } }
      );
    }

    // 4. Mapear o resultado
    const items = data.map((item: any) => ({
        mes: item.mes,
        label: item.label,
        Novilha: Number(item.Novilha),
        Primípara: Number(item.Primípara),
        Multípara: Number(item.Multípara)
    }));

    // 5. Retornar o JSON de sucesso
    return new Response(
      JSON.stringify({ ok: true, items }),
      { status: 200, headers: { 'Content-Type': 'application/json', ...corsHeaders } }
    );
  } catch (error) {
    console.error('Erro geral da função:', error);
    return new Response(
      JSON.stringify({ ok: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json', ...corsHeaders } }
    );
  }
});
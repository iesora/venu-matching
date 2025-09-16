import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { creatorURL } from "@/utils/url/creator";
import { Creator } from "@/type";
import { AxiosError } from "axios";

const getCreatorById = async (id: string): Promise<Creator> => {
  const response = await axiosInstance.get(`${creatorURL}/${id}`);
  return response.data;
};

export const useAPIGetCreatorById = (id: string) => {
  return useQuery<Creator, AxiosError>({
    queryKey: ["creator", id],
    queryFn: () => getCreatorById(id),
    enabled: !!id, // idが存在する場合のみクエリを実行
  });
};

import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { creatorURL } from "@/utils/url/creator";
import { Creator } from "@/type";
import { AxiosError } from "axios";

const getCreators = async () => {
  const response = await axiosInstance.get(creatorURL);
  return response.data;
};

export const useAPIGetCreators = () => {
  return useQuery<Creator[], AxiosError>({
    queryKey: ["creators"],
    queryFn: () => getCreators(),
  });
};
